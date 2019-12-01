function Get-PowerPromptDefaultTheme {
    param (
        [Switch]$AsScriptBlock
    )

    $promptScript = {
        $LastCommandSucceeded = $?
        trap {write-host -fore red "PROMPT ERROR: $($PSItem.exception.message). `$error[0] for more information" } #; $PSItem | export-clixml $home\desktop\prompterror.clixml

        $ErrorActionPreference = 'stop'

        $prompt = New-PowerPromptBuilder

        $gitStatus = Get-GitStatus -AsPrompt
        if ($gitStatus -and -not $PowerPromptSettings.HideGitStatus) {
            $prompt += @{
                PromptText      = $gitStatus
                BackgroundColor = '#007ACC'
            }
        }

        $tfWorkspace = Get-TerraformWorkspace
        if ($tfWorkspace) {
            $prompt += @{
                PromptText      = $tfWorkspace
                BackgroundColor = '#6044E7'
            }
        }

        $prompt2 = New-PowerPromptBuilder

        $debugMode = Get-IsDebugMode
        if ($debugMode) {
            $prompt2 += @{
                PromptText      = $debugMode
                BackgroundColor = '#CC6633'
            }
        }

        $prompt2 += @{
            PromptText      = Get-PowerPromptCurrentDirectory
            BackgroundColor = '#333333'
        }

        if (-not $prompt.prompt.count) {
            $promptOutput = [String]$prompt2
        } else {
            $promptOutput = [String]$prompt,[String]$prompt2 -join [Environment]::NewLine
        }


        return $promptOutput
    }

    if ($AsScriptBlock) {
        return $PromptScript
    } else {
        $GLOBAL:PowerPromptScript = $PromptScript
        function GLOBAL:prompt {Invoke-Command -ScriptBlock $GLOBAL:PowerPromptScript}
    }

}