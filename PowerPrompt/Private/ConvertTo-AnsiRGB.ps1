function ConvertTo-AnsiRGB {
    [Cmdletbinding()]
    param (
        #Takes a Drawing.Color Name or a #RRGGBB HTML color string
        [String]$Color,
        #By default it converts to a background color. Specify this for a foreground color.
        [switch]$Foreground,
        #If specified with foreground switch, will display either white or black depending on the background color's brightness
        [switch]$Auto
    )

    [Drawing.Color]$ColorObject = if ($Color -match '^#\w{6}$') {
        #Convert HTML Hex colors to a corresponding color
        [Drawing.ColorTranslator]::FromHtml($Color)
    } else {
        [Drawing.Color]::$Color
    }
    if (-not $ColorObject) {throw "Color $Color is not a valid Color Name or #RRGGBB style HTML color code"}

    if ($ForeGround -and $Auto) {
        if (Test-IsLightColor $ColorObject) {
            $ColorObject = [Drawing.Color]::Black
        } else {
            $ColorObject = [Drawing.Color]::White
        }
    }

    if ($psedition -eq 'core') {
        $e = "`e"
    } else {
        $e = [char]0x1b
    }
    $fgCode = "$e[38;2;"
    $bgCode = "$e[48;2;"
    $ansiCode = if ($Foreground) {$fgCode} else { $bgCode }

    return "$ansiCode{0};{1};{2}m" -f
    $ColorObject.r,
    $ColorObject.g,
    $ColorObject.b
}