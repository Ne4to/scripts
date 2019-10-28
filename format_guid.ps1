[CmdletBinding()]
param(
    [string]$Guid,
    [switch]$FromClipboard,
    [switch]$ToClipboard,
    [ValidateSet("None", "Single", "Double")]
    [string]$OutputQuotes = "None"
)

Set-StrictMode -Version "Latest"

# Install-Module -Name ClipboardText

if ($FromClipboard){
    $Guid = Get-ClipboardText
}

$GuidValue = [System.Guid]::Parse($Guid)
$Result = $GuidValue.ToString("D")

switch ($OutputQuotes) {
    "Single" { $Result = '''' + $Result + '''' }
    "Double" { $Result = '"' + $Result + '"' }
}

if ($ToClipboard){
    Set-ClipboardText $Result
} else {
    Write-Output $Result
}