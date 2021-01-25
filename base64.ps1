[CmdletBinding()]
param(
  [string]$SourceFilePath,
  [string]$SourceString,
  [switch]$FromClipboard,
  [switch]$ToClipboard,
  [string]$TargetFilePath,
  [ValidateSet("Encode", "Decode")]
  [string]$Mode = 'Encode'
)

if ($Mode -eq "Encode") {
    if ($SourceFilePath) {
        $Bytes = [IO.File]::ReadAllBytes($SourceFilePath)
    }

    $Base64 = [Convert]::ToBase64String($Bytes)

    if ($ToClipboard) {
        Set-ClipboardText $Base64
    }

    if ($TargetFilePath) {
        [IO.File]::WriteAllText($TargetFilePath, $Base64)
    }
}

if ($Mode -eq "Decode") {
    $Base64 = ''

    if ($SourceFilePath) {
        $Base64 = [IO.File]::ReadAllText($SourceFilePath)
    }

    if ($SourceString) {
        $Base64 = $SourceString
    }

    if ($FromClipboard) {
        $Base64 = Get-ClipboardText
    }

    $Bytes = [Convert]::FromBase64String($Base64)

    if ($ToClipboard) {
        throw "ToClipboard is not supported, use TargetFilePath"
        # Set-ClipboardText $Base64
    }

    if ($TargetFilePath) {
        [IO.File]::WriteAllBytes($TargetFilePath, $Bytes)
    }
}