[CmdletBinding()]
param(
  [string]$ModulesRoot = "$HOME\projects\GitHub\Ne4to\scripts\modules"
)

Get-Module |
  Where-Object {
    $_.ModuleType -eq 'Script' -and $_.Path.StartsWith($ModulesRoot)
  } |
  ForEach-Object {
    Write-Host "Processing $($_.Path)"
    Remove-Module $_.Name
    Import-Module $_.Path
  }