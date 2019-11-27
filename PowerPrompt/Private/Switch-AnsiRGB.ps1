#Switches a foregroundcolor to a backgroundcolor and vice versa
function Switch-AnsiRGB ($AnsiColorCode) {
    #First try background to foreground
    $result = $AnsiColorCode -replace '(?<=^\e\[)48(?=.+)','38'
    #If it didn't match try the other direction
    if ($result -eq $AnsiColorCode) {
        $result = $AnsiColorCode -replace '(?<=^\e\[)38(?=.+)','48'
    }

    #If it still didn't match, bail out
    if ($result -eq $AnsiColorCode) {throw "A proper Ansi 24-bit RGB Color Code was not provided"}
    return $result
}