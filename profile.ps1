Import-Module posh-git
Import-Module oh-my-posh

Get-ChildItem "$($env:HOME)\projects\GitHub\Ne4to\scripts\modules" -Filter *.psm1 -Recurse |
ForEach-Object { Import-Module $_.FullName }

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# setup kubectl aliases
$HasKubectlAliases = Test-Path "$Home\Documents\PowerShell\kubectl_aliases.ps1"
if (! $HasKubectlAliases) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/shanoor/kubectl-aliases-powershell/master/kubectl_aliases.ps1" -OutFile "$Home\Documents\PowerShell\kubectl_aliases.ps1"
}

. $Home\Documents\PowerShell\kubectl_aliases.ps1

# setup oh-my-posh theme
$themeName = "tehrob-ne4to"
$theme = get-theme | Where-Object Name -eq $themeName
if (! $theme) {
    $version = [string](get-module oh-my-posh).Version
    Copy-Item "$Home\projects\GitHub\Ne4to\scripts\external\$themeName.psm1" "$Home\Documents\PowerShell\Modules\oh-my-posh\$version\Themes\$themeName.psm1"
}

Set-Theme $themeName