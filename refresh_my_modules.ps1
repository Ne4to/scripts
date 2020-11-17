Get-Module |
  Where-Object {
    $_.ModuleType -eq 'Script' -and $_.Path.StartsWith("$($env:HOME)\projects\GitHub\Ne4to\scripts\modules")
  } |
  ForEach-Object {
    Remove-Module $_.Name
    Import-Module $_.Path
  }