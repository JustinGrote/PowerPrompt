Describe "Default Theme" {

    ipmo C:\Users\JGrote\Projects\PowerPrompt\PowerPrompt\PowerPrompt.psd1 -force

    #Function Prompt
    $LastCommandSucceeded = $?
    trap {write-host -fore red "PROMPT ERROR: $($PSItem.exception.message). `$error[0] for more information" } #; $PSItem | export-clixml $home\desktop\prompterror.clixml
    $ErrorActionPreference = 'stop'

    $prompt = New-PowerPromptBuilder

    $prompt += @{
        PromptText      = Get-PowerPromptCurrentDirectory
        BackgroundColor = '#333333'
    }

    write-host $prompt
}