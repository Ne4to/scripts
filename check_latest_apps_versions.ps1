[CmdletBinding()]
param(
    [switch]$Download,
    [switch]$Install
)

Set-StrictMode -Version 'Latest'

if ($Install) {
    $Download = $true
}

function Get-LatestGitHubRelease {
    param (
        $User,
        $Repository
    )

    $Uri = "https://api.github.com/repos/$User/$Repository/releases/latest"
    $Response = Invoke-RestMethod -Uri $Uri
    $LatestVersion = New-Object -TypeName System.Management.Automation.SemanticVersion -ArgumentList $Response.tag_name.substring(1)

}

$Response = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
$LatestVersion = New-Object -TypeName System.Management.Automation.SemanticVersion -ArgumentList $Response.tag_name.substring(1)
$CurrentVersion = $PSVersionTable.PSVersion

# if ($LatestVersion -gt $CurrentVersion) {
    Write-Host "New version available $LatestVersion, current is $CurrentVersion"

    if ($Download) {
        $DownloadUrl = ($Response.assets | Where-Object { $_.name.contains('win-x64.msi') }).browser_download_url
        Write-Host $DownloadUrl
        $FileName = ([Uri]$DownloadUrl).Segments[-1]
        Write-Host $FileName
        $OutPath = Join-Path $env:TEMP $FileName
        Write-Host $OutPath
        Invoke-RestMethod -Uri $DownloadUrl -OutFile $OutPath
    }
# }

# https://github.com/gitextensions/gitextensions/releases
# Get-Command 'C:\Program Files (x86)\GitExtensions\GitExtensions.exe'
# TODO file not exists
# Version = 3.0.2.5232
# GitExtensions-3.0.2.5232.msi


# https://github.com/FarGroup/FarManager/releases
# Far.x64.3.0.5383.829.f6b91726a05c7a904be6b32b103a48bba4b5b1cc.msi
# Get-Command 'C:\Program Files\Far Manager\Far.exe'
# Version = 3.0.4455.0




# https://api.github.com/repos/Microsoft/vscode/tags?page=1