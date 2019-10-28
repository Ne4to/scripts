# TODO legacy, use scoop install rclone

$apps = "../apps"
$rcloneRoot = "$apps/rclone"
New-Item -ItemType Directory $rcloneRoot

$tempDirPath = "$env:TEMP\rclone_$(Get-Date -Format FileDateTime)"
New-Item -ItemType Directory $tempDirPath

$zipPath = "$tempDirPath\rclone.zip"
#$outPath = "$tempDirPath\out"

Invoke-WebRequest "https://downloads.rclone.org/rclone-current-windows-amd64.zip" -OutFile $zipPath
Unblock-File $zipPath
Expand-Archive $zipPath $tempDirPath

$src =(Get-ChildItem "$tempDirPath\*windows-amd64" -Directory).FullName
Copy-Item "$src\*" $rcloneRoot -Recurse