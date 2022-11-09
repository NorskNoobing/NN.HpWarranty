#Requires -Module ModuleBuilder
[string]$moduleName = "NN.HpWarranty"
[version]$version = "0.0.1"
[string]$author = "NorskNoobing"
[string]$ProjectUri = "https://github.com/$author/$moduleName"
[string]$releaseNotes = "Initial commit"
[string]$description = "HP Warranty API integration"
[array]$tags = @("HP","Warraty","API")
[version]$PSversion = "7.2"

$manifestSplat = @{
    "Description" = $description
    "PowerShellVersion" = $PSversion
    "Tags" = $tags
    "ReleaseNotes" = $releaseNotes
    "Path" = "$PSScriptRoot\source\$moduleName.psd1"
    "RootModule" = "$moduleName.psm1"
    "Author" = $author
    "ProjectUri" = $ProjectUri
}
New-ModuleManifest @manifestSplat

$buildSplat = @{
    "SourcePath" = "$PSScriptRoot\source\$moduleName.psd1"
    "Version" = $version
}
Build-Module @buildSplat