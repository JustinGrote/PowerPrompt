#Used for Powershell 5.1 for extended emoji characters
function Get-Unicode ([String[]]$UnicodeChars) {
    $result = New-Object Text.StringBuilder
    $UnicodeChars.Split(' ').foreach{
        $char = [Char]::ConvertFromUtf32(
            [Convert]::ToInt32(($PSItem -replace '^U\+'),16)
        )
        $result.append($char) > $null
    }
    [String]$result
}