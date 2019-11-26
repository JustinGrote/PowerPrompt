function StripAnsi ([String]$String) {
    $stripAnsiRegex = "\e\[(\d+;)*(\d+)?[ABCDHJKfmsu]"
    return ($String -replace $stripAnsiRegex,'')
}