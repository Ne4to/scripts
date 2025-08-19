#Requires -Version 7

[CmdletBinding()]
param(
  [string]$FilePath = 'D:\temp\bsp_metrics_01.txt'
)

Set-StrictMode -Version 'Latest'

$MetricSeparators = @('{', ' ')
$MetricRows = @{}

Get-Content -Path $FilePath | ForEach-Object {
    $Line = $_
    if ($Line.StartsWith('#')) { return }
    $Index = $Line.IndexOfAny($MetricSeparators)
    if ($Index -eq -1) { Write-Host $Line; return }
    $MetricName = $Line.Substring(0, $Index)
    if ($MetricRows.ContainsKey($MetricName)) {
      $MetricRows[$MetricName] = $MetricRows[$MetricName] + 1
    } else {
      $MetricRows[$MetricName] = 1
    }
}

# $MetricRows.GetEnumerator() | Select-Object { $_.Key }
$Stat = @()
$MetricRows.GetEnumerator() |
  ForEach-Object {
    $Stat += [pscustomobject]@{
      metric = $_.Key
      qty = $_.Value
    }
  }

$Stat |
  Where-Object -Property qty -GT 10 |
  Sort-Object -Property qty -Descending