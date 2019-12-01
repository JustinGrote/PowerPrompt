Describe "Default Theme" {

    #Mock various variables to trigger prompt detections
    Push-Location TestDrive:/
    mkdir .terraform
    echo "pester" > .terraform/environment
    ipmo C:\Users\JGrote\Projects\PowerPrompt\PowerPrompt\PowerPrompt.psd1 -force
    & (gmo powerprompt) {$SCRIPT:PPDebugMock = $true}

    if (get-command 'git' -CommandType Application -ErrorAction SilentlyContinue) {
        $null = git init *>&1
        $null = git checkout -b pester *>&1
    }

    #Function Prompt
    $promptscript = Get-PowerPromptDefaultTheme -asScriptBlock
    Write-Host (Invoke-Command $promptScript)

    Pop-Location
}