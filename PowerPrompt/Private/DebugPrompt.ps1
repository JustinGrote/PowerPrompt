function DebugPrompt ([String]$Prompt,[Switch]$Escaped) {
    if ($Escaped) {
        write-debug "Escaped Prompt: $($Prompt -replace '\e','E')"
    } else {
        $myPrompt = $prompt -replace '\e','E' `
        -replace 'E\[39;49m','<RESETCOLOR>' `
        -replace 'E\[38;2;(.+?)m','<FGCOLOR:$1>' `
        -replace 'E\[48;2;(.+?)m','<BGCOLOR:$1>'
        write-debug "Human Readable Prompt: $myPrompt"
    }
}