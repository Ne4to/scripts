[CmdletBinding()]
param(
  [string]$SourceFilePath,
  [switch]$ToClipboard
)

[xml]$XmlConfig = Get-Content $SourceFilePath

$JsonConfig = @{}

Select-Xml '/configuration/appSettings/add' $XmlConfig |
    Select-Object -ExpandProperty Node |
    Select-Object -Property key,value |
    ForEach-Object {
        $JsonConfig[$_.key] = $_.value
    }

$Result = $JsonConfig | ConvertTo-Json

if ($ToClipboard) {
    Set-ClipboardText $Result
} else {
    $Result
}
