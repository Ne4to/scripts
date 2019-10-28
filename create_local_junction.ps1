[CmdletBinding()]
param(
    [string]$appsRoot = "C:\apps",
    [string]$scriptsRoot = "C:\scripts",
    [ValidateSet("Consumer", "Commercial")]
    [string]$OneDrive = "Consumer"
)

$oneDriveRoot =  switch ($OneDrive) {
    "Consumer" { $env:OneDriveConsumer }
    "Commercial" { $env:OneDriveCommercial }
}

if (-Not (Test-Path $oneDriveRoot)) {
    throw "OneDrive path $oneDriveRoot is not found"
}

New-Item -ItemType Directory $appsRoot -Force | Out-Null
New-Item "$appsRoot\rclone" -ItemType Junction -Value "$oneDriveRoot\portable\apps\rclone" -ErrorAction SilentlyContinue | Out-Null

New-Item -ItemType Directory $scriptsRoot -Force | Out-Null
New-Item $scriptsRoot -ItemType Junction -Value "$oneDriveRoot\portable\scripts" -ErrorAction SilentlyContinue | Out-Null