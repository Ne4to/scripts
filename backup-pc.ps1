[CmdletBinding()]
param(
    [SecureString]$ArchivePassword,
    [switch]$SkipSsh,
    [switch]$SkipDesktop
)

$ErrorActionPreference = 'Stop'

if (!$ArchivePassword -and !$SkipSsh) {
    throw 'You must specify $ArchivePassword to backup SSH keys otherwise use -SkipSsh parameter'
}

if (!$env:OneDriveConsumer) {
    throw "Environment variable OneDriveConsumer is not found"
}

if (!(Test-Path $env:OneDriveConsumer)) {
    throw "OneDrive path $($env:OneDriveConsumer) is not found"
}

$StartTime = get-date

# test on static folder
# $TempFolder = 'C:\Users\Ne4to\AppData\Local\Temp\tmp-7aebac56-fd7d-4959-94b1-8e2a97012ab4'
# Remove-Item -Force -Recurse $TempFolder

$TempFolder = "$($Env:temp)\tmp-$([System.Guid]::NewGuid().ToString("D"))"
Write-Host "Using temp folder: $TempFolder"
New-Item -ItemType Directory -Path $TempFolder  | Out-Null

# SSH keys
if (!$SkipSsh) {
    Copy-Item "~/.ssh" $TempFolder -Recurse
}

# Git config
Copy-Item "~/.gitconfig" $TempFolder

# PowerShell profile
Copy-Item $PROFILE "$TempFolder\profile.ps1"

# Environment variables
Get-ChildItem env: | Select-Object Key, Name, Value | Export-Csv "$TempFolder\env.csv"

# winget export
Write-Progress 'winget export'
. winget export -o "$TempFolder\winget.json" 3>&1 2>&1 > "$TempFolder\winget.log"

# Desktop
if (!$SkipDesktop) {
    Write-Progress 'Desktop'
    Copy-Item "~/Desktop" $TempFolder -Recurse
}

# Projects
Write-Progress 'Projects' -CurrentOperation 'Clean'

Get-ChildItem -Path "~/projects" -Directory -Recurse -Filter bin | Remove-Item -Recurse
Get-ChildItem -Path "~/projects" -Directory -Recurse -Filter obj | Remove-Item -Recurse
Get-ChildItem -Path "~/projects" -Directory -Recurse -Filter app | Remove-Item -Recurse
Get-ChildItem -Path "~/projects" -Directory -Recurse -Filter node_modules | Remove-Item -Recurse

Write-Progress 'Projects' -CurrentOperation 'Archive'
Compress-Archive -Path "~/projects" -DestinationPath "$TempFolder\projects.zip" -CompressionLevel NoCompression

if (!(Get-Module 7Zip4Powershell -ListAvailable)) {
    Install-Module -Name 7Zip4Powershell -Force
}
$TempArchivePath = "$TempFolder.7z"
Write-Information "Archiving to $TempArchivePath"
Compress-7zip -Path $TempFolder -ArchiveFileName "$TempFolder.7z" -Format SevenZip -CompressionLevel Fast -SecurePassword $ArchivePassword

# copy to OneDrive
$BackupRootFolder = Join-Path $env:OneDriveConsumer "backups" $env:COMPUTERNAME
New-Item $BackupRootFolder -ItemType Directory -Force -ErrorAction 'SilentlyContinue' | Out-Null
$BackupArchivePath = "$BackupRootFolder\$(Get-Date -Format "yyyy-MM-dd-HHmm").7z"
Copy-Item $TempArchivePath $BackupArchivePath
Write-Information "Backup stored in $BackupArchivePath"

# cleanup
Remove-Item -Force $TempArchivePath
Remove-Item -Force -Recurse $TempFolder

$RunTime = New-TimeSpan -Start $StartTime -End (get-date)
Write-Information "Completed in $RunTime"