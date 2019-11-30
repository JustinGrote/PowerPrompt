
function Add-PowerPrompt {
    <#
    .SYNOPSIS
    Builds a powerline-style prompt from segments
    .DESCRIPTION
    This command is used to build a prompt from existing segments, and automagically will figure out the colors for the
    separators as necessary. You can insert additional colors into your string with ANSI escape sequences (don't use reset)
    #>
    [CmdletBinding()]
    param (
        #The additional prompt segment to add
        [Parameter(Mandatory)][String]$InputObject,
        #The prompt string to append to
        [Parameter(ValueFromPipeline)][String]$Prompt,
        #The separator to use. Defaults to Powerline Separator.
        [String]$Separator = [char]0xe0b4,
        #The previous separator to use when appending to an existing prompt. Defaults to a generic separator match of up to 3 characters.
        [String]$LastSeparator,
        #The name of a background color. If not specified a random color will be chosen
        [String]$BackgroundColor,
        #The name of a foreground color. If not specified this function will automatically choose based on background
        [String]$ForegroundColor,
        #The separator color to use for the background of the separator
        [String]$SeparatorBackgroundColor,
        #The separator color to use for the foreground of the separator
        [String]$SeparatorForegroundColor
    )

    begin {
        if ($PSEdition -eq 'Desktop' -and -not ('system.drawing' -as [type])) {
            #We need to load the drawing assembly from GAL
            Add-Type -Assembly System.Drawing
        }

        #Set some "constants"
        if ($psedition -eq 'core') {
            $e = "`e"
        } else {
            $e = [char]0x1b
        }
        $resetColors = "$e[39;49m"
    }

    process { foreach ($promptItem in $prompt) {
        #write-host -fore magenta ("Add-PowerPrompt Begin: {0}" -f ($prompt -replace "$([char]0x1b)",'e'))
        if (-not $inputObject) {return}

        if (-not $BackgroundColor) {
            $backgroundColor = ("AliceBlue","AntiqueWhite","Aqua","Aquamarine","Azure","Beige","Bisque","Black","BlanchedAlmond","Blue","BlueViolet","Brown","BurlyWood","CadetBlue","Chartreuse","Chocolate","Coral","CornflowerBlue","Cornsilk","Crimson","Cyan","DarkBlue","DarkCyan","DarkGoldenrod","DarkGray","DarkGreen","DarkKhaki","DarkMagenta","DarkOliveGreen","DarkOrange","DarkOrchid","DarkRed","DarkSalmon","DarkSeaGreen","DarkSlateBlue","DarkSlateGray","DarkTurquoise","DarkViolet","DeepPink","DeepSkyBlue","DimGray","DodgerBlue","Empty","Firebrick","FloralWhite","ForestGreen","Fuchsia","Gainsboro","GhostWhite","Gold","Goldenrod","Gray","Green","GreenYellow","Honeydew","HotPink","IndianRed","Indigo","Ivory","Khaki","Lavender","LavenderBlush","LawnGreen","LemonChiffon","LightBlue","LightCoral","LightCyan","LightGoldenrodYellow","LightGray","LightGreen","LightPink","LightSalmon","LightSeaGreen","LightSkyBlue","LightSlateGray","LightSteelBlue","LightYellow","Lime","LimeGreen","Linen","Magenta","Maroon","MediumAquamarine","MediumBlue","MediumOrchid","MediumPurple","MediumSeaGreen","MediumSlateBlue","MediumSpringGreen","MediumTurquoise","MediumVioletRed","MidnightBlue","MintCream","MistyRose","Moccasin","NavajoWhite","Navy","OldLace","Olive","OliveDrab","Orange","OrangeRed","Orchid","PaleGoldenrod","PaleGreen","PaleTurquoise","PaleVioletRed","PapayaWhip","PeachPuff","Peru","Pink","Plum","PowderBlue","Purple","Red","RosyBrown","RoyalBlue","SaddleBrown","Salmon","SandyBrown","SeaGreen","SeaShell","Sienna","Silver","SkyBlue","SlateBlue","SlateGray","Snow","SpringGreen","SteelBlue","Tan","Teal","Thistle","Tomato","Transparent","Turquoise","Violet","Wheat","White","WhiteSmoke","Yellow","YellowGreen" | Get-Random)
        }

        $bgColorCode = ConvertTo-AnsiRGB -Color $BackgroundColor

        if (-not $ForegroundColor) {
            $fgColorCode = ConvertTo-AnsiRGB -Color $BackgroundColor -Foreground -Auto
        } else {
            $fgColorCode = ConvertTo-AnsiRGB -Color $ForegroundColor -Foreground
        }
        #TODO: Separator Styles
        if (-not $SeparatorBackgroundColor) {
            $separatorBackgroundColorCode = Switch-AnsiRGB $bgColorCode
        } else {
            $separatorBackgroundColorCode = ConvertTo-AnsiRGB -Color $SeparatorBackgroundColor
        }
        if ($SeparatorForegroundColor) {
            $separatorForegroundColorCode += ConvertTo-AnsiRGB -Color $SeparatorForegroundColor -Foreground
        }

        [String]$PSPromptEnd = "${resetColors}${separatorBackgroundColorCode}${separatorForegroundColorCode}${Separator}${resetColors}"
        [String]$PSPromptSegment = "${bgColorCode}${fgColorCode}${InputObject}${PSPromptEnd}"

        #If there is no existing prompt, stop here and render as a new prompt segment
        if (-not $Prompt) {
            #Render the new prompt segment
            return $PSPromptSegment
        }

        #Detect the current end prompt and use it as the basis to join the two segments together
        $promptWithSeparator = Split-PromptSeparator $Prompt

        #If the last separator only had a foreground color, assume it is a powerline Style
        #TODO: Separator Styles
        if ($PromptWithSeparator.separator.ForegroundColorCode -and -not $PromptWithSeparator.separator.BackgroundColorCode) {
            $separatorForegroundColorCode = $promptWithSeparator.separator.ForegroundColorCode
            $separatorBackgroundColorCode = $bgColorCode
            $Separator = $promptWithSeparator.separator.separator
        }

        #Reattach the prompt separator that flows to the new prompt segment
        $Prompt = $promptWithSeparator.BasePrompt + "${separatorBackgroundColorCode}${separatorForegroundColorCode}${Separator}${resetColors}"

        #Append the new segment to the existing prompt fragment
        $Prompt += $PSPromptSegment

        return $prompt
    }}
}