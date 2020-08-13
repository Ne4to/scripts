#Requires -Version 7

if (!(Get-Module posh-git -ListAvailable)) {
    Install-Module posh-git
}
Import-Module posh-git

if (!(Get-Module oh-my-posh -ListAvailable)) {
    Install-Module oh-my-posh
}
Import-Module oh-my-posh

# `scoop install fzf` first 
if (!(Get-Module PSFzf -ListAvailable)) {
    Install-Module -Name PSFzf
}
Import-Module PSFzf

$modulesPath = Join-Path -Path ~ -ChildPath "projects\GitHub\Ne4to\scripts\modules"
if (Test-Path $modulesPath) {
    Get-ChildItem $modulesPath -Filter *.psm1 -Recurse |
        ForEach-Object {
            Import-Module $_.FullName
        }
}

# if (Test-Path "$($ThemeSettings.MyThemesLocation)\*") {
#     Get-ChildItem -Path "$($ThemeSettings.MyThemesLocation)\*" -Include '*.psm1'

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# setup kubectl aliases
# $HasKubectlAliases = Test-Path "$Home\Documents\PowerShell\kubectl_aliases.ps1"
# if (! $HasKubectlAliases) {
#     Invoke-WebRequest -Uri "https://raw.githubusercontent.com/shanoor/kubectl-aliases-powershell/master/kubectl_aliases.ps1" -OutFile "$Home\Documents\PowerShell\kubectl_aliases.ps1"
# }

. $Home\projects\GitHub\Ne4to\scripts\kubectl_aliases.ps1
function kksd() { & kubectl ksddotnet get secret -oyaml $args }
function time {
    Param([ScriptBlock]$cmd)
    Measure-Command { . $cmd | Out-Default } |
        Select-Object TotalSeconds
}

# setup oh-my-posh theme
$themeName = "tehrob-ne4to"
$theme = get-theme | Where-Object Name -eq $themeName
if (! $theme) {
    $version = [string](get-module oh-my-posh).Version
    Copy-Item "$Home\projects\GitHub\Ne4to\scripts\external\$themeName.psm1" "$Home\Documents\PowerShell\Modules\oh-my-posh\$version\Themes\$themeName.psm1"
}

Set-Theme $themeName
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'