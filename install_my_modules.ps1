Get-ChildItem "c:\scripts\modules" -Filter *.psm1 -Recurse |
    ForEach-Object { Import-Module $_.FullName }