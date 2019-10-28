[CmdletBinding()]
param(
  [int]$MinSizeKb = 10
)

Set-StrictMode -Version 'Latest'

'
FROM mcr.microsoft.com/powershell

WORKDIR /app
COPY . /build-context
WORKDIR /build-context
CMD pwsh -c ''$MinSize = [int]($env:MIN_SIZE_KB)*1024;\
  Write-Host "Min size: $env:MIN_SIZE_KB Kb";\

  Get-ChildItem -Recurse -File |\
    Where-Object Length -gt $MinSize |\
    Select-Object -Property FullName,Length |\
    Sort-Object Length |\
    Format-Table -Wrap @{Label = "Size(Kb)"; Expression = {[int]($_.Length / 1024)}},@{Label = "FullName"; Expression = {$_.FullName.Substring(14)}} |\
    Out-String -Width 220 ''
' | docker build -t build-context -f - . | Out-Null

# $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(200,55);

docker run --rm --env MIN_SIZE_KB=$MinSizeKb build-context