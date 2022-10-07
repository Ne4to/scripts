[CmdletBinding()]
param(
    [switch]$ToClipboard,
    [ValidateSet("D", "N")]
    [string]$FormatString = "D",
    [ValidateSet("None", "Single", "Double")]
    [string]$OutputQuotes = "None"
)

Set-StrictMode -Version "Latest"

# Install-Module -Name ClipboardText
#1..5 | Foreach { .\create_guid.ps1 -FormatString N }

$Result = ""


$GuidValue = [System.Guid]::NewGuid()
$Result = $GuidValue.ToString($FormatString)

switch ($OutputQuotes) {
    "Single" { $Result = '''' + $Result + '''' }
    "Double" { $Result = '"' + $Result + '"' }
}

if ($ToClipboard){
    Set-Clipboard $Result
} else {
    Write-Output $Result
}