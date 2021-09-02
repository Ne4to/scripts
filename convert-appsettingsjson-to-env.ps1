<#
.SYNOPSIS
  The script converts .NET appsettings.json configuration file to Environment variables format

.NOTES
  dot (`.`) couldn't be used in config keys: https://github.com/dotnet/runtime/issues/35989

.EXAMPLE
  ./convert-appsettingsjson-to-env.ps1 -SourceFilePath 'appsettings.Development.json' -EnvKeyPrefix 'K8S_SECRET_' | Format-List

.LINK
  JSON configuration provider: https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/#jcp

.LINK
  Environment variables: https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/#evcp
#>

[CmdletBinding()]
param(
  [parameter(Mandatory = $true)]
  [string]$SourceFilePath,
  [string]$EnvKeyPrefix = ''
)

$Root = Get-Content -Path $SourceFilePath |
  ConvertFrom-Json -AsHashtable

function Get-EnvVars {
  param (
    [Hashtable]$Root,
    [string]$RootKeyPrefix
  )

  $EnvKeys = @{}

  foreach ($Key in $Root.Keys) {
    $KeyPrefix = "$RootKeyPrefix$Key"
    $Value = $Root[$Key]

    if ($Value -is [Hashtable]) {
      $EnvKeys += Get-EnvVars -Root $Value -RootKeyPrefix "${KeyPrefix}__"
    } elseif ($Value -is [array]) {
      for ($ArrayIndex = 0; $ArrayIndex -lt $Value.Count; $ArrayIndex++) {
        $EnvKeys += Get-EnvVars -Root $Value[$ArrayIndex] -RootKeyPrefix "${KeyPrefix}__${ArrayIndex}__"
      }
    } else {
      $EnvKeys += @{$KeyPrefix=$Value}
    }
  }

  return $EnvKeys
}

$EnvVars = Get-EnvVars -Root $Root -RootKeyPrefix $EnvKeyPrefix
$EnvVars.GetEnumerator() | Sort-Object -Property key