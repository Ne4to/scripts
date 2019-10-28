Import-Module posh-git
Import-Module oh-my-posh
Set-Theme ParadoxWithDuration

Get-ChildItem "c:\scripts\modules" -Filter *.psm1 -Recurse |
    ForEach-Object { Import-Module $_.FullName }