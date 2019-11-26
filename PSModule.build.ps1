#requires -version 5.1

#PowerCD Bootstrap
. $PSScriptRoot\PowerCD.buildinit.ps1

Enter-Build {
    Initialize-PowerCD
}

task . PowerCD.Default

# task PowerCD.Nuget {
#     function PowerCD.Nuget {
#         [CmdletBinding()]
#         param (
#             [Parameter(ValueFromRemainingArguments)]$Args
#         )
#         $PSModuleNugetDependencies = Import-PowershellDataFile 'PSModule.nugetrequirements.psd1'
#         Get-PSModuleNugetDependencies $PSModuleNugetDependencies -Destination (join-path $PCDSetting.BuildModuleOutput 'lib') -NoRestore -verbose
#     }
#     PowerCD.Nuget
# }

# task PowerCD.TestPester {
#     Test-PowerCDPester -CodeCoverage $null -Show All -ModuleManifestPath $PCDSetting.OutputModuleManifest -UseJob
# }