using namespace System
using namespace System.Net
using namespace System.Collections.Generic
Function Get-Secret {
    <#
    .SYNOPSIS
        Retrieve SecretServer credentials.
    .DESCRIPTION
        Uses Thycotic Secret Server SOAP Api to obtain the requested Secret, by its ID
        and returns them to the user as a PSCredential.

        This module has an exported list variable called $SecretList, which contains a 
        mapping of Service account names to SecretIds for convenience.  You can view 
        this list by typing $SecretList in a terminal that has SmartResponse.Framework 
        imported.
    .PARAMETER SecretId
        ID correcsponding to a stored credential in Secret Server. 
        You can find this by examining the URL of a SecretView page. Example:
        https://secretserver.domain.com/SecretView.aspx?secretid=79884
    .PARAMETER Credential
        (Optional) [PSCredential] object to authenticate to Secret Server. By default, 
        the caller's account (DefaultCredential) will be used for authentication.
    .PARAMETER AuthFilePath
        (Optional) Path to serialized [PSCredential] object for authenticating to 
        Secret Server. You can store a [PSCredential] in a file with the following 
        command:

            PS C:\> Get-Credential | Export-CliXml -Path \path\to\credfile.xml
    .INPUTS
        A [PSCredential] object can be provided to Get-Secret through the pipeline.
    .OUTPUTS
        A [PSCredential] object for the requested secret.
    .NOTES
        ** Callers should consider using a Try/Catch block when using Get-Secret. **

        If any error occurs during execution of the Get-Secret cmdlet, an exception will 
        be thrown, some of which may be non-terminating for upstream scripts. Try/Catch
        will ensure you know if there was any issue or not.
    .EXAMPLE
        Get-Secret -SecretId 81823
        ---
        Description: Gets [PSCredential] for Secret Id 81823 with your default crednetials.
    .EXAMPLE
        PS C:\> $SvcAccount = Get-Secret -SecretId $SecretList.SvcSecCAMgmt
        ---
        Description: Retrieves the secret for AD account SvcSecADMgmt from Secret 
        Server and stores it in variable $Credential. The user's own credentials are 
        used for authentication to SecretServer.
    .EXAMPLE
        PS C:\> $MyCred = ($SvcAccount | Get-Secret -SecretId 12345)
        ---
        Description: Authenticate to SecretServer using credentials saved in $SvcAccount to
        retrieve the Secret Id 12345 into $MyCred
    .EXAMPLE
        PS C:\> $Token = $Get-Secret -SecretId $SecretList.WDATPAuthKey -AuthFilePath c:\tmp\mycred.xml
        ---
        Description: Credentials for SecretServer are deserialized from mycred.xml file and
        used to authenticate to Secret Server. The WDATPAuthKey credential is stored in $Token.
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>
    #region: Parameters
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $SecretId,

        [Parameter(Mandatory=$false,Position=1, ValueFromPipeline=$true)]
        [pscredential] $Credential,

        [Parameter(Mandatory=$false, Position=2)]
        [string] $AuthFilePath,

        [Parameter(Mandatory=$false, Position=3)]
        [string] $SecretServerUrl = 
            "https://secretserver.domain.com/winauthwebservices/sswinauthwebservice.asmx"
    )
    # Verbose Parameter
    $Verbose = $false
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
        $Verbose = $true
    }
    # Trust all certs, use Tls1.2
    Write-IfVerbose "Calling Enable-TrustAllCertsPolicy from ApiHelper.dll" $Verbose -ForegroundColor Yellow
    Enable-TrustAllCertsPolicy
    # Set Return Object
    $ReturnCredential = $null
    #endregion



    #region: SecretServer Credentials
    # Load Credential File if provided.
    if ($AuthFilePath) {
        if (Test-Path $AuthFilePath) {
            Write-IfVerbose "Loading SecretServer credential from: $AuthFilePath" $Verbose
            try {
                $Credential = Import-CliXml -Path $AuthFilePath
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        } else {
            throw [exception] "Unable to find credential file at: $AuthFilePath"
        }
    }
    #endregion



    #region: Authenticate to Secret Server
    try {
        if ($Credential) {
            Write-IfVerbose "SecretServer authentication $($Credential.UserName)" $Verbose -ForegroundColor Yellow
            $SecretServerService = New-WebServiceProxy -uri $SecretServerUrl -Credential $Credential -ErrorAction Stop
        } else {
            $SecretServerService = New-WebServiceProxy -uri $SecretServerUrl -UseDefaultCredential -ErrorAction Stop
        }
    }
    catch [Exception] {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
    #endregion



    #region: Secret API Request
    try {
        $RequestResult = $SecretServerService.GetSecret($SecretId, $false, $null)
    }
    catch [Exception] {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
    
    if ($RequestResult.Errors.length -gt 0) {
        throw [WebException]::new($RequestResult.Errors)
    } else {
        $ReturnCredential = New-Object System.Management.Automation.PSCredential `
        -ArgumentList @(`
            $RequestResult.Secret.Items[1].Value, `
            (ConvertTo-SecureString -String  $RequestResult.Secret.Items[2].Value -AsPlainText -Force))
    }
    #endregion

    return $ReturnCredential
}