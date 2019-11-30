
Describe "Split-PromptSeparator" {
    . "$PSScriptRoot\..\PowerPrompt\Private\Split-PromptSeparator.ps1"

    It "Splits a prompt" {
        $prompt = import-clixml $PSScriptRoot/Mocks/pesterprompt1.clixml
        $result = Split-PromptSeparator $prompt
        #[regex]::Escape($result.baseprompt) -replace '\e','\e'
        $result.BasePrompt | Should -match '^\e\[48;2;255;0;0m\e\[38;2;255;255;255mpester1\e\[39;49m$'
        $result.Separator.Separator | Should -Be "$([char]0xe0b4)"
        $result.Separator.ForegroundColorCode | Should -Match '^\e\[38;2;255;0;0m$'
    }
}

