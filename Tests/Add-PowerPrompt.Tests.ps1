Describe "Add-PowerPrompt" {

    function DebugPrompt ([String]$Prompt) {
        write-debug "Prompt: $Prompt"
        write-debug "Escaped Prompt: $($Prompt -replace '\e','E')"
    }

    import-module $PSScriptRoot\..\PowerPrompt\PowerPrompt.psd1 -force
    $testCases = @(
        @{
            Prompt = $null
            InputObject = 'pester1'
            Result = (import-clixml $PSScriptRoot\Mocks\pesterprompt1.clixml)
            Background = 'red'
        }
        @{
            Prompt = (import-clixml $PSScriptRoot\Mocks\pesterprompt1.clixml)
            InputObject = 'pester2'
            Result = (import-clixml $PSScriptRoot\Mocks\pesterprompt2.clixml)
            Background = 'blue'
        }
        @{
            Prompt = (import-clixml $PSScriptRoot\Mocks\pesterprompt2.clixml)
            InputObject = 'pester3'
            Result = (import-clixml $PSScriptRoot\Mocks\pesterprompt3.clixml)
            Background = 'pink'
        }
    )

    It 'Adds <InputObject> to Prompt' -TestCases $testCases {
        param($prompt,$inputobject,$result,$background,$foreground)
        Add-PowerPrompt -prompt $prompt -inputobject $inputobject -background $background -OutVariable Output
        DebugPrompt $Output
        $Output | Should -Be $result
    }

    It 'Processes a custom separator with multiple characters properly' {
        $Result = Import-CliXml $PSScriptRoot\Mocks\pestercustomseparator.clixml
        Add-PowerPrompt -prompt $null -inputobject 'pesterCustomSeparator' -Separator '>|>' -back blue -OutVariable Output
        DebugPrompt $Output
        $Output | Should -Be $result
    }

    It 'Adds a segment with a different separator properly' {
        $Prompt = Import-Clixml $PSScriptRoot\Mocks\pestercustomseparator.clixml
        $Result = Import-CliXml $PSScriptRoot\Mocks\pestercustomseparator2.clixml
        Add-PowerPrompt -prompt $Prompt -inputobject 'pesternormalseparator' -Separator ([char]0xE0C0) -back cyan -OutVariable Output
        DebugPrompt $Output
        $Output | Should -Be $Result
    }

    It 'Adds a segment via the pipeline' {
        $Prompt = Import-Clixml $PSScriptRoot\Mocks\pestercustomseparator.clixml
        $Result = Import-CliXml $PSScriptRoot\Mocks\pestercustomseparator2.clixml
        $Prompt | Add-PowerPrompt 'pesternormalseparator' -Separator ([char]0xE0C0) -back cyan -OutVariable Output
        DebugPrompt $Output
        $Output | Should -Be $Result
    }
}