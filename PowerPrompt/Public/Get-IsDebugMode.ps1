function Get-IsDebugMode {
    if ((Test-Path variable:/psdebugcontext) -or $PPDebugMock) {
        if ($PowerPromptSettings.SupportsEmoji) {
            Unicode '1F41E' #Lady Beetle
        } elseif ($PowerPromptSettings.SupportsNerdFont) {
            [char]0xf188
        } else {
            '[DBG]'
        }
    }
}
