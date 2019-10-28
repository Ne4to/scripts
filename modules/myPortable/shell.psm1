Set-StrictMode -Version 'Latest'

function Set-ParentLocation {
  [CmdletBinding()]
  param (
    [int]$Depth = 1
  )

  for ($i = 0; $i -lt $Depth; $i++) {
    Set-Location ..
  }
}

function SPL1 {Set-ParentLocation -Depth 1}
Set-Alias -Name .. -Value SPL1
function SPL2 {Set-ParentLocation -Depth 2}
Set-Alias -Name ... -Value SPL2
function SPL3 {Set-ParentLocation -Depth 3}
Set-Alias -Name .... -Value SPL3
function SPL4 {Set-ParentLocation -Depth 4}
Set-Alias -Name ..... -Value SPL4

Export-ModuleMember -Function Set-ParentLocation
Export-ModuleMember -Function SPL1,SPL2,SPL3,SPL4
Export-ModuleMember -Alias ..,...,....,.....