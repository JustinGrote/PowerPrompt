
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
        [String]$Background,
        #The name of a foreground color. If not specified this function will automatically choose based on background
        [String]$Foreground
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
        $fgcode = "$e[38;2;"
        $bgcode = "$e[48;2;"
    }

    process { foreach ($promptItem in $prompt) {
        #write-host -fore magenta ("Add-PowerPrompt Begin: {0}" -f ($prompt -replace "$([char]0x1b)",'e'))
        if (-not $inputObject) {return}
        if ($Background) {
            $bgColorItem = $Background
        } else {
            $bgColorItem = ("AliceBlue","AntiqueWhite","Aqua","Aquamarine","Azure","Beige","Bisque","Black","BlanchedAlmond","Blue","BlueViolet","Brown","BurlyWood","CadetBlue","Chartreuse","Chocolate","Coral","CornflowerBlue","Cornsilk","Crimson","Cyan","DarkBlue","DarkCyan","DarkGoldenrod","DarkGray","DarkGreen","DarkKhaki","DarkMagenta","DarkOliveGreen","DarkOrange","DarkOrchid","DarkRed","DarkSalmon","DarkSeaGreen","DarkSlateBlue","DarkSlateGray","DarkTurquoise","DarkViolet","DeepPink","DeepSkyBlue","DimGray","DodgerBlue","Empty","Firebrick","FloralWhite","ForestGreen","Fuchsia","Gainsboro","GhostWhite","Gold","Goldenrod","Gray","Green","GreenYellow","Honeydew","HotPink","IndianRed","Indigo","Ivory","Khaki","Lavender","LavenderBlush","LawnGreen","LemonChiffon","LightBlue","LightCoral","LightCyan","LightGoldenrodYellow","LightGray","LightGreen","LightPink","LightSalmon","LightSeaGreen","LightSkyBlue","LightSlateGray","LightSteelBlue","LightYellow","Lime","LimeGreen","Linen","Magenta","Maroon","MediumAquamarine","MediumBlue","MediumOrchid","MediumPurple","MediumSeaGreen","MediumSlateBlue","MediumSpringGreen","MediumTurquoise","MediumVioletRed","MidnightBlue","MintCream","MistyRose","Moccasin","NavajoWhite","Navy","OldLace","Olive","OliveDrab","Orange","OrangeRed","Orchid","PaleGoldenrod","PaleGreen","PaleTurquoise","PaleVioletRed","PapayaWhip","PeachPuff","Peru","Pink","Plum","PowderBlue","Purple","Red","RosyBrown","RoyalBlue","SaddleBrown","Salmon","SandyBrown","SeaGreen","SeaShell","Sienna","Silver","SkyBlue","SlateBlue","SlateGray","Snow","SpringGreen","SteelBlue","Tan","Teal","Thistle","Tomato","Transparent","Turquoise","Violet","Wheat","White","WhiteSmoke","Yellow","YellowGreen" | Get-Random)
        }
        if ($bgColorItem -match '^#\w{6}$') {
            #Convert HTML Hex colors to a corresponding color
            $bgColor = [Drawing.ColorTranslator]::FromHtml($bgColorItem)
        } else {
            $bgColor = [Drawing.Color]::$bgColorItem
        }

        if ($bgColor) {
            if ($Foreground) {
                if ($ForeGround -match '^#\w{6}$') {
                    #Convert HTML Hex colors to a corresponding color
                    $fgColor = [Drawing.ColorTranslator]::FromHtml($Foreground)
                } else {
                    $fgColor = [Drawing.Color]::$Foreground
                }
            } else {
                #Select the appropriate foreground color based on the background
                if (Test-IsLightColor $bgColor) {
                    $fgColor = [Drawing.Color]::Black
                } else {
                    $fgColor = [Drawing.Color]::White
                }
            }

            #Convert to RGB format for consistency
            $bgColorCode = "$bgcode{0};{1};{2}m" -f
                $bgColor.r,
                $bgColor.g,
                $bgcolor.b
            $separatorColorCode = "$fgcode{0};{1};{2}m" -f
                $bgColor.r,
                $bgColor.g,
                $bgcolor.b
            $fgColorCode = "$fgcode{0};{1};{2}m" -f
                $fgColor.r,
                $fgColor.g,
                $fgColor.b
        } else {
            $bgColorCode = $resetColors
        }

        [String]$PSPromptEnd = "${resetColors}${separatorColorCode}${Separator}${resetColors}"
        [String]$PSPromptSegment = "${bgColorCode}${fgColorCode}${InputObject}${PSPromptEnd}"

        if (-not $Prompt) {
            #Render the new prompt segment
            return $PSPromptSegment
        }

        #If there is a prompt, let's first detect the separator
        $ansiColorCodeRegex = "\e\[[34]8;2;\d{1,3};\d{1,3};\d{1,3}m"
        $resetColorRegex = [Regex]::Escape($resetColors)

        #Generic matcher for PSPromptEnd, regardless of color
        $lastSeparatorRegex = if ($lastSeparator) {
            [Regex]::Escape($lastSeparator)
        } else {
            #Match 1 to 3 characters of any type.
            #TODO: Get better separator matcher
            '.{1,3}'
        }

        $PSPromptEndRegex = "(.+?${resetColorRegex}${ansiColorCodeRegex})(?<lastSeparator>${lastSeparatorRegex})${resetColorRegex}$"
        if ($Prompt -match $PSPromptEndRegex) {
            #Strip off the separator and color reset and add in the color of the upcoming segment so the segments "flow" together
            #Then reset colors again and only preserve the background to
            $Prompt = $Prompt -replace $PSPromptEndRegex,('$1' + $bgColorCode + $matches.lastSeparator)
        } else {
            write-warning "Couldn't detect the last separator character $lastSeparator, assuming you meant to do this and ignoring."
        }

        #Append the new segment to the prompt fragment
        $Prompt += $PSPromptSegment

        return $prompt
    }}
}