[CmdletBinding()]
param(
  [switch]$ToClipboard
)

Set-StrictMode -Version "Latest"

# $RootPath = (Resolve-Path .\).Path
$Result = ""

Get-ChildItem -Recurse global.json,*.sln,*.csproj |
  ForEach-Object {
    $RelativePath = Resolve-Path $_.FullName -Relative
    # $TargetPath = $RelativePath.Replace('src\', '')
    $TargetPath = $RelativePath
    $Command = -join("COPY ", $RelativePath, " ", $TargetPath)
    $Command = $Command.Replace('\', '/')

    $Result += "$Command"
    $Result += [System.Environment]::NewLine
  }

if ($ToClipboard){
    Set-ClipboardText $Result
} else {
    Write-Output $Result
}