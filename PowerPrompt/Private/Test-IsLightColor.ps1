function Test-IsLightColor ([Drawing.Color]$Color) {
    #https://stackoverflow.com/a/36888120/5511129
    [double]$luma = ((0.299 * $Color.R) + (0.587 * $Color.G) + (0.114 * $Color.B)) / 255
    $luma -gt 0.5
}