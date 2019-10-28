$OneDriveConsumer = $env:OneDriveConsumer
$OneDriveCommercial = $env:OneDriveCommercial

if (-Not $OneDriveConsumer -or -Not (Test-Path $OneDriveConsumer)) {
    throw "OneDrive Consumer path $OneDriveConsumer is not found"
}

if (-Not $OneDriveCommercial -or -Not (Test-Path $OneDriveCommercial)) {
    throw "OneDrive Commercial path $OneDriveCommercial is not found"
}

$rclonePath = "C:\apps\rclone\rclone.exe"
& $rclonePath copy "$OneDriveConsumer\portable" "$OneDriveCommercial\portable" --exclude-from "$OneDriveConsumer\portable\scripts\rclone_exclude_list"