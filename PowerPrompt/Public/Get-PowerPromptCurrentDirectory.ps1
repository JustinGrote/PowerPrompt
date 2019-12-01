function Get-PowerPromptCurrentDirectory {
    [CmdletBinding()]
    param (
        #Don't abbreviate the home directory to a character
        [Switch]$NoHomeAbbreviation,
        #Don't use emojis for home directory abbreviation if available
        [Switch]$NoHomeEmoji,
        #Don't abbreviate the projects folder
        [Switch]$NoProjectsAbbreviation,
        #Don't use an emoji for the Projects folder if available
        [Switch]$NoProjectsEmoji
    )

    [String]$currentDirectory = $executionContext.SessionState.Path.CurrentLocation
    if (-not $NoHomeAbbreviation) {
        $homePathRegex = "^$([Regex]::Escape($home))"
        if ($NoHomeEmoji -or -not $PowerPromptSettings.SupportsEmoji) {
            $HomeGlyph = '~'
        } else {
            $homeGlyph = Unicode '1F3E0' #House
        }
        $currentDirectory = $currentDirectory -replace $homePathRegex, $HomeGlyph
    }

    if ($PowerPromptSEttings.SupportsEmoji -and -not $noProjectsEmoji) {
        $ProjectsGlyph = Unicode 1F6A7 # Construction Emoji
    } elseif ($PowerPromptSettings.SupportsNerdFont -and -not $NoProjectsEmoji) {
        $ProjectsGlyph = Unicode e20f # Wrench and Screwdriver Nerdfont version
    }

    if ($ProjectsGlyph) {
        $pathChar = [regex]::Escape([io.path]::DirectorySeparatorChar)
        if (-not $NoProjectsAbbreviation) {
            $projectsPathRegex = "(?<=^.+${pathChar})projects(?=${pathChar}?)"
        }

        $currentDirectory = $currentDirectory -replace $projectsPathRegex,$ProjectsGlyph
    }

    return $currentDirectory
}