function GetPathIfFileExist($Path, $File) {
    if (-not $Path) {
        return
    } elseif (Test-Path (Join-Path $Path $File)) {
        $Path
    } else {
        GetPathIfFileExist (Split-Path $Path) $File
    }
}