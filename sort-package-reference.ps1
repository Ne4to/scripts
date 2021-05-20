# [CmdletBinding()]
# param(
#     [switch]$FromClipboard,
#     [switch]$ToClipboard
# )

Set-StrictMode -Version 'Latest'

[xml]$XmlConfig = Get-ClipboardText

[System.XML.XMLDocument]$Doc = New-Object System.Xml.XmlDocument
[System.XML.XMLElement]$Root = $Doc.CreateElement('ItemGroup')
$Doc.appendChild($Root) | Out-Null

Select-Xml '/ItemGroup/PackageReference' $XmlConfig |
    Select-Object -ExpandProperty Node |
    Select-Object -Property Include,Version |
    Sort-Object -Property Include |
    ForEach-Object {
        $Child = $Root.AppendChild($Doc.CreateElement('PackageReference'))

        $IncludeAttr = $Doc.CreateAttribute("Include")
        $IncludeAttr.Value = $_.Include
        $Child.SetAttributeNode($IncludeAttr) | Out-Null

        $VersionAttr = $Doc.CreateAttribute("Version")
        $VersionAttr.Value = $_.Version
        $Child.SetAttributeNode($VersionAttr) | Out-Null
    }

$StringWriter = New-Object System.IO.StringWriter

$Settings = New-Object System.Xml.XmlWriterSettings
$Settings.OmitXmlDeclaration = $true
$Settings.Indent = $true

$Writer = [System.Xml.XmlWriter]::Create($StringWriter, $Settings);
$Doc.Save($Writer)

Set-ClipboardText $StringWriter.ToString()