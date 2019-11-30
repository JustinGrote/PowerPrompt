function Split-PromptSeparator ([String]$Prompt,[String]$lastSeparator) {
    #Set some "constants"
    if ($psedition -eq 'core') {
        $e = "`e"
    } else {
        $e = [char]0x1b
    }
    $resetColors = "$e[39;49m"
    $fgcode = "$e[38;2;"
    $bgcode = "$e[48;2;"
    $ansiColorCodeRegex = "\e\[[34]8;2;\d{1,3};\d{1,3};\d{1,3}m"
    $ansiBGColorCodeRegex = "\e\[48;2;(?<r>\d{1,3});(?<g>\d{1,3});(?<b>\d{1,3})m"
    $ansiFGColorCodeRegex = "\e\[38;2;(?<r>\d{1,3});(?<g>\d{1,3});(?<b>\d{1,3})m"
    $resetColorRegex = [Regex]::Escape($resetColors)

    #Generic matcher for PSPromptEnd, regardless of color
    $lastSeparatorRegex = if ($lastSeparator) {
        [Regex]::Escape($lastSeparator)
    } else {
        #Match 1 to 3 characters of any type.
        #TODO: Get better separator matcher
        '.{1,3}'
    }

    #Construct the segment matching regex
    $PSPromptLastSeparatorRegex = "(.+?${resetColorRegex})(?<lastcolor>${ansiColorCodeRegex})(?<lastcolor2>${ansiColorCodeRegex})?(?<lastSeparator>${lastSeparatorRegex})${resetColorRegex}$"

    if ($Prompt -match $PSPromptLastSeparatorRegex) {
        #The next -replace will overwrite $matches, so we need to preserve it now
        $promptMatches = $matches

        $result = @{}
        $result.Separator = $matches.lastSeparator

        #Detect the foreground and background colors if present
        foreach ($colorItem in $promptMatches.lastColor,$PromptMatches.lastColor2) {
            if ($ColorItem) {
                if ($ColorItem -match $ansiBGColorCodeRegex) {
                    $result.BackgroundColorCode = $ColorItem
                } elseif ($ColorItem -match $ansiFGColorCodeRegex) {
                    $result.ForegroundColorCode = $colorItem
                } else {
                    throw "Get-PromptSeparator matched an ANSI color but it was not a foreground or background color code. This should not happen and is probably a bug."
                }
            }
        }

        #Strip the separator and its formatting colors
        $BasePrompt = $Prompt -replace $PSPromptLastSeparatorRegex,'$1'

        return @{
            BasePrompt = $BasePrompt
            Separator = $result
        }
    } else {
        write-warning "Couldn't detect a separator. Assuming you meant to do this and ignoring."
    }
}