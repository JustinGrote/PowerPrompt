

Describe "PromptBuilder" {
    function DebugPrompt ([String]$Prompt) {
        write-debug "Prompt: $Prompt"
        write-debug "Escaped Prompt: $($Prompt -replace '\e','E')"
    }

    import-module $PSScriptRoot\..\PowerPrompt\PowerPrompt.psd1 -force
    InModuleScope PowerPrompt {
        Context "Constructors" {
            It "Empty" {
                [PromptBuilder]::new().gettype().Name | Should -Be 'PromptBuilder'
            }
            It "String" {
                $Result = Import-Clixml $PSScriptRoot\Mocks\promptbuilder.clixml
                $promptBuilder = [PromptBuilder]'pesterPrompt'
                $promptBuilder | Should -Not -BeNullOrEmpty
                $promptBuilder.ToString() | Should -Be $Result
            }
        }

        Context "Add" {
            It "HashTable" {
                $promptbuilder = [PromptBuilder]::new()
                $promptbuilder.Add(@{
                    PromptText = 'pester'
                    BackgroundColor = 'red'
                    ForegroundColor = 'blue'
                })
                write-host ([String]$PromptBuilder)
            }
        }
    }


}