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

    # if ('AddYamlFile' -notin (get-typedata "Microsoft.Extensions.Configuration.ConfigurationBuilder").members.keys) {
    #     Update-TypeData -TypeName Microsoft.Extensions.Configuration.ConfigurationBuilder -MemberName AddYamlFile -MemberType ScriptMethod -Value {
    #         param([String]$Path)
    #         [Microsoft.Extensions.Configuration.YamlConfigurationExtensions]::AddYamlFile($this, $Path)
    #     }
    # }