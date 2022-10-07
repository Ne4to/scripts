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

function SPL1 { Set-ParentLocation -Depth 1 }
Set-Alias -Name .. -Value SPL1
function SPL2 { Set-ParentLocation -Depth 2 }
Set-Alias -Name ... -Value SPL2
function SPL3 { Set-ParentLocation -Depth 3 }
Set-Alias -Name .... -Value SPL3
function SPL4 { Set-ParentLocation -Depth 4 }
Set-Alias -Name ..... -Value SPL4

function Set-LocationToProjects {
  $FullPath = Join-Path -Path $HOME "projects"
  Set-Location $FullPath
}
Set-Alias -Name cdp -Value Set-LocationToProjects

function Get-LastCommandDuration {
  $lastCmd = Get-History -Count 1
  if ($null -ne $lastCmd) {
    $cmdTime = $lastCmd.Duration.TotalMilliseconds
    $units = "ms"
    if ($cmdTime -ge 1000) {
      $units = "s"
      $cmdTime = $lastCmd.Duration.TotalSeconds
      if ($cmdTime -ge 60) {
        $units = "m"
        $cmdTime = $lastCmd.Duration.TotalMinutes
      }
    }

    $cmdTime = "$($cmdTime.ToString("#.##"))$units"
    return $cmdTime
  }
}


Export-ModuleMember -Function Set-ParentLocation, Set-LocationToProjects, Get-LastCommandDuration
Export-ModuleMember -Function SPL1, SPL2, SPL3, SPL4
Export-ModuleMember -Alias .., ..., ...., ....., cdp