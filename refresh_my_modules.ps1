Get-Module |
  Where-Object {
    $_.ModuleType -eq 'Script' -and $_.Path.StartsWith('C:\scripts')
  } |
  ForEach-Object {
    Remove-MOdule $_.Name
    Import-Module $_.Path
  }