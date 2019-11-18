Get-ChildItem "$($env:HOME)\projects\GitHub\Ne4to\scripts\modules" -Filter *.psm1 -Recurse |
    ForEach-Object { Import-Module $_.FullName }