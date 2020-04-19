Import-Module posh-git
Import-Module oh-my-posh
# Set-Theme Powerlevel10k-LeanWithDuration

Get-ChildItem "$($env:HOME)\projects\GitHub\Ne4to\scripts\modules" -Filter *.psm1 -Recurse |
    ForEach-Object { Import-Module $_.FullName }

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

. $Home\Documents\PowerShell\kubectl_aliases.ps1

Set-Theme tehrob2