[CmdletBinding()]
param(
    [string]$scriptsRoot = "C:\scripts"
)

$scriptsSource = "$HOME\projects\GitHub\Ne4to\scripts"

if (-Not (Test-Path $scriptsSource)) {
    throw "OneDrive path $scriptsSource is not found"
}

New-Item -ItemType Directory $scriptsRoot -Force | Out-Null
New-Item $scriptsRoot -ItemType Junction -Value $scriptsSource -ErrorAction SilentlyContinue | Out-Null