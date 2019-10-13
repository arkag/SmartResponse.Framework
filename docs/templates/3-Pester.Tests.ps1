$CmdletName = ($MyInvocation.MyCommand.Name).Split(".")[0]
Describe "SmartResponse.Framework: $CmdletName" {
    # Import Test Data
    $TestData = Get-Content -Path "$PSScriptRoot\$CmdletName.TestData.json" -Raw | ConvertFrom-Json

    # Initialize Test
    $TestRoot = (([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent).FullName
    . (Join-Path $TestRoot "Initialize-Test.ps1")
    Initialize-Test


    
    Context "Functionality Test" {

        It "Does Something" {

        }
    }
}