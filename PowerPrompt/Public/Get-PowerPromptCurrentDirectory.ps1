function Get-PowerPromptCurrentDirectory {
    [CmdletBinding()]
    param (
        #Don't abbreviate the home directory to a character
        [Switch]$NoHomeAbbreviation,
        #Don't use emojis for home directory abbreviation if available
        [Switch]$NoHomeEmoji
    )

    [String]$currentDirectory = $executionContext.SessionState.Path.CurrentLocation
    if (-not $SkipHomeAbbreviate) {
        $homePathRegex = "^$([Regex]::Escape($home))"
        if ($NoHomeEmoji) {
            $HomeGlyph = '~'
        } else {
            $homeGlyph = Unicode '1F3E0' #House
        }
        $currentDirectory = $currentDirectory -replace $homePathRegex, $HomeGlyph
    }

    return $currentDirectory
}