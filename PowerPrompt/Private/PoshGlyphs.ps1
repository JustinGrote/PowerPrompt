function Get-GlyphNerdFonts ($Name) {
    $cache = [Runtime.Caching.MemoryCache]::Default
    if ($cache['poshglyph-nfcollection']) {
        $nfCollection = $cache['poshglyph-nfcollection']
    } else {
        [Regex]$glyphRegex = '<span><div class="class-name">(?<name>[\S<>]+)</div><div class="codepoint">(?<codepoint>\w+)</div></span>'
        $glyphRegexMatches = $glyphRegex.Matches((Invoke-RestMethod -useb 'https://www.nerdfonts.com/'))

        $nfcollection = [ordered]@{ }

        foreach ($glyphItem in $glyphRegexMatches) {
            $nfCollection.Add(
                ($glyphItem.Groups['name'] -replace '^nf-', ''),
                [char][int]("0x" + $glyphItem.Groups['codepoint'])
            )
        }
        $cache['poshglyph-nfcollection'] = $nfCollection
    }

    if ($Name) {
        return $nfCollection.$Name
    } else {
        return $nfCollection
    }
}

function Get-GlyphEmoji ($Name) {
    [CmdletBinding()]

    $cache = [Runtime.Caching.MemoryCache]::Default
    if ($cache['poshglyph-emojicollection']) {
        $emojiCollection = $cache['poshglyph-emojicollection']
    } else {
        $emojiList = Invoke-RestMethod -UseBasicParsing 'https://unpkg.com/emoji.json/emoji.json'
        $emojiCollection = [ordered]@{ }
        foreach ($emojiItem in $emojiList) {
            $emojiCollection[$emojiItem.Name] = $emojiItem.char
        }
        $cache['poshglyph-emojicollection'] = $emojiCollection
    }

    if ($Name) {
        return $emojiCollection.$Name
    } else {
        return $emojiCollection
    }
}

function Get-GlyphAnsiEscape ($Name) {
    $ansiCollection = [ordered]@{ }
    enum AnsiColors {
        Black
        Red
        Green
        Yellow
        Blue
        Magenta
        Cyan
        White
    }
    $template = "`e[{0}{1}m"
    $brightCode = ';1'
    foreach ($colorItem in [AnsiColors]::GetValues([AnsiColors])) {
        $ansiCollection["$ColorItem"] = $template -f [int][AnsiColors]($ColorItem + 30), $null
        $ansiCollection["Bright$ColorItem"] = $template -f [int][AnsiColors]($ColorItem + 30), $brightCode
        $ansiCollection["BG${ColorItem}"] = $template -f [int][AnsiColors]($ColorItem + 40), $null
        $ansiCollection["BGBright${ColorItem}"] = $template -f [int][AnsiColors]($ColorItem + 40), $brightCode
    }

    $specialkeys = @{
        Reset     = $template -f 0, $null
        Bold      = $template -f 1, $null
        Underline = $template -f 4, $null
        Reversed  = $template -f 7, $null
    }

    $specialkeys.keys | ForEach-Object {
        $ansiCollection[$PSItem] = $SpecialKeys[$PSItem]
    }

if ($Name) {
    return $ansiCollection.$Name
} else {
    return $ansiCollection
}

}
function Get-GlyphXTerm ([String]$Name) {
    [CmdletBinding()]

    $cache = [Runtime.Caching.MemoryCache]::Default
    if ($cache['poshglyph-xtermcollection']) {
        $xtermCollection = $cache['poshglyph-xtermcollection']
    } else {
        $xtermList = Invoke-RestMethod -UseBasicParsing 'https://jonasjacek.github.io/colors/data.json'
        $xtermCollection = [ordered]@{ }
        foreach ($xtermItem in $xtermList) {
            $xtermColorID = $xtermItem.colorId
            $xtermCollection[$xtermItem.name] = "`e[38;5;{0}m" -f $xtermColorID
            $xtermCollection["BG$($xtermItem.name)"] = "`e[48;5;{0}m" -f $xtermColorID
        }

        $cache['poshglyph-xtermcollection'] = $xtermCollection
    }

    if ($Name) {
        return $xtermCollection.$Name
    } else {
        return $xtermCollection
    }
}

function Get-GlyphAnsiTrueColor {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        #The name of the color you want
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'Name')][Drawing.KnownColor]$Name,
        #A hex color code such as HTML style (#FFFF08) or hex style (0xFFFF08). Alpha is ignored
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'Hex')][int32]$HexColorCode,
        #Provide an existing color object
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'Color')][Drawing.Color]$Color,
        #Select this if you want the color to toggle a background color
        [Switch]$Background
    )
    switch ($PSCmdlet.ParameterSetName) {
        'Name' {
            $Color = [Drawing.Color]::$Name
        }
        'Hex' {
            $Color = [Drawing.ColorTranslator]::FromHtml($HexColorCode)
        }
    }

    if ($background) { $colorType = '48' } else { $colorType = '38' }
    return ("`e[{0};2;{1};{2};{3}m" -f $colorType, $Color.R, $Color.G, $Color.B)
}