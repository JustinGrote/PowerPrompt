Describe "ConvertTo-AnsiRGB" {
    function DebugPrompt ([String]$Prompt) {
        write-debug "Prompt: $Prompt"
        write-debug "Escaped Prompt: $($Prompt -replace '\e','E')"
    }

    import-module $PSScriptRoot\..\PowerPrompt\PowerPrompt.psd1 -force
    InModuleScope PowerPrompt {
        It 'Converts Blue' {
            (ConvertTo-AnsiRGB 'Blue') -replace '\e','e' | Should -Be 'e[48;2;0;0;255m'
        }
        It 'Converts Blue Foreground' {
            (ConvertTo-AnsiRGB 'Blue' -Foreground) -replace '\e','e' | Should -Be 'e[38;2;0;0;255m'
        }
        It 'Converts #2211AA' {
            (ConvertTo-AnsiRGB 'Blue') -replace '\e','e' | Should -Be 'e[48;2;0;0;255m'
        }
    }
}