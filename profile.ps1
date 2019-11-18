Import-Module posh-git
Import-Module oh-my-posh
Set-Theme ParadoxWithDuration

Get-ChildItem "$($env:HOME)\projects\GitHub\Ne4to\scripts\modules" -Filter *.psm1 -Recurse |
    ForEach-Object { Import-Module $_.FullName }