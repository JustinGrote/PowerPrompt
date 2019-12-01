#region SourceInit
$publicFunctions = @()
foreach ($ScriptPathItem in 'Private','Public','Classes') {
    $ScriptSearchFilter = [io.path]::Combine($PSScriptRoot, $ScriptPathItem, '*.ps1')
    Get-ChildItem $ScriptSearchFilter | Foreach-Object {
        if ($ScriptPathItem -eq 'Public') {$PublicFunctions += $PSItem.BaseName}
        . $PSItem
    }
}
#endregion SourceInit

$GLOBAL:PowerPromptSettings = @{}
if ($host.ui.SupportsVirtualTerminal) {
    $PowerPromptSettings.SupportsANSI = $true
}

if ($env:WT_SESSION) {
    $PowerPromptSettings.SupportsEmoji = $true

    #TODO: Better nerd prompt determination
    $PowerPromptSettings.SupportsNerdFont = $true
}

if ($env:TERM_PROGRAM -eq 'vscode') {
    $PowerPromptSettings.HideGitStatus = $true

    #TODO: Better nerd prompt determination
    $PowerPromptSettings.SupportsNerdFont = $true
}

