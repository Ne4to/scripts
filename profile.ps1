#Requires -Version 7

# requirements
# - install oh-my-posh: winget install JanDeDobbeleer.OhMyPosh
# - fzf first: https://github.com/junegunn/fzf/releases
# - install fonts: https://github.com/ryanoasis/nerd-fonts/releases/

if (!(Get-Module Terminal-Icons -ListAvailable)) {
    Install-Module Terminal-Icons
}
Import-Module Terminal-Icons

# install fzf first
if (!(Get-Module PSFzf -ListAvailable)) {
    Install-Module -Name PSFzf
}
Import-Module PSFzf

# install PSReadLine
if (!(Get-Module PSReadLine -ListAvailable)) {
    Install-Module PSReadLine -AllowPrerelease -Force
}
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

$modulesPath = Join-Path -Path ~ -ChildPath "projects\github.com\Ne4to\scripts\modules"
if (-not (Test-Path $modulesPath)) {
    $modulesPath = Join-Path -Path ~ -ChildPath "projects\GitHub\Ne4to\scripts\modules"
}

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
if (Test-Path $Home\projects\github.com\Ne4to\scripts\kubectl_aliases.ps1) {
    . $Home\projects\github.com\Ne4to\scripts\kubectl_aliases.ps1
}
if (Test-Path $Home\projects\GitHub\Ne4to\scripts\kubectl_aliases.ps1) {
    . $Home\projects\GitHub\Ne4to\scripts\kubectl_aliases.ps1
}
function krrd() { & kubectl rollout restart deployment $args }
function kksd() { & kubectl ksddotnet get secret -oyaml $args }
function time {
    Param([ScriptBlock]$cmd)
    Measure-Command { . $cmd | Out-Default } |
        Select-Object TotalSeconds
}

function watch {
    Param(
        [ScriptBlock]$cmd,
        [int]$Seconds = 1
    )

    while ($true) {
        . $cmd | Out-Default
        Write-Host
        Start-Sleep -Seconds $Seconds
    }
}
function cpwd {
    Get-Location | Set-Clipboard
}

# setup oh-my-posh
if (Test-Path $Home\projects\GitHub\Ne4to\scripts\jandedobbeleer.omp.json) {
    oh-my-posh --init --shell pwsh --config $Home\projects\GitHub\Ne4to\scripts\jandedobbeleer.omp.json | Invoke-Expression
}

if (Test-Path $Home\projects\github.com\Ne4to\scripts\jandedobbeleer.omp.json) {
    oh-my-posh --init --shell pwsh --config $Home\projects\github.com\Ne4to\scripts\jandedobbeleer.omp.json | Invoke-Expression
}

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'