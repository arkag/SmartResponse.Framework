using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Retire-LrIdentity {
    <#
    .SYNOPSIS
        Retire an Identity from TrueIdentity based on TrueID #.
    .DESCRIPTION
        Retire-LrIdentity returns an object containing the detailed results of the retired Identity.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER IdentityId
        Unique Identifier ID # for a TrueID record.
    .OUTPUTS
        PSCustomObject representing LogRhythm TrueIdentity Identity and its retirement status.
    .EXAMPLE
        PS C:\> Retire-LrIdentity -IdentityId 11
        ----
        identityID        : 11
        nameFirst         : Marcus
        nameMiddle        :
        nameLast          : Burnett
        displayIdentifier : marcus.burnett@contoso.com
        company           : Contoso
        department        : IT
        title             : IT Helpdesk Admin
        manager           : Jade Falkesan
        addressCity       :
        domainName        :
        entity            : @{entityId=1; rootEntityId=0; path=Primary Site; name=Primary Site}
        dateUpdated       : 2020-04-15T18:30:08.86Z
        recordStatus      : Retired
        identifiers       : {@{identifierID=40; identifierType=Login; value=marcus.burnett; recordStatus=Active; source=}, @{identifierID=41; identifierType=Login; value=marcus.burnett@contoso.com;
                            recordStatus=Active; source=}, @{identifierID=42; identifierType=Login; value=marcus.burnett_sup; recordStatus=Active; source=}, @{identifierID=43; identifierType=Email;
                            value=marcus.burnett@contoso.com; recordStatus=Active; source=}}
        groups            : {@{name=Domain Admins}}

    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiCredential,

        [Parameter(Mandatory = $true, ValueFromPipeline=$true, Position = 1)]
        [long]$IdentityId
    )

    Begin {
        # Request Setup
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")

        $Method = $HttpMethod.Put

        # Establish Body Contents
        $BodyContents = [PSCustomObject]@{
            recordStatus = "Retired"
        } | ConvertTo-Json
    }

    Process {        
        # Define Query URL
        $RequestUrl = $BaseUrl + "/identities/" + $IdentityId + "/status"

        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method -Body $BodyContents
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
            $PSCmdlet.ThrowTerminatingError($PSItem)
            return $false
        }
    }

    End { 
        return $Response
    }
}