function Get-TerraformWorkspace {
<#
.SYNOPSIS
Lightweight Terraform workspace detection, returns the workspace if not default
#>
    $tfenvpath = '.terraform/environment'
    $tfpath = GetPathIfFileExist $pwd $tfenvpath

    #TODO:Remove
    $tfWorkspace = if ($tfpath) {Get-Content (join-path $tfpath $tfenvpath)}
    $tfIcon = $null
    if ($tfworkspace) {
        if ($PowerPromptSettings.SupportsNerdFont) {
            $tficon = Unicode 'f6a6'
        } else {
            $tficon = (Unicode '20b8') + ' '
        }

        $tficon + $tfworkspace
    }
}