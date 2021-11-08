# make a backup
if (Test-Path $profile) {
    $PathSuffix = Get-Date -Format ".yyyy-MM-dd-HHmmss.bak"
    $TargetPath = $profile + $PathSuffix
    Copy-Item $profile $TargetPath
}

$GitHubProfilePath = Join-Path -Path $HOME -ChildPath "projects\GitHub\Ne4to\scripts\profile.ps1"
if (Test-Path $GitHubProfilePath) {
    Remove-Item $profile -Force -ErrorAction SilentlyContinue
    New-Item $profile -ItemType SymbolicLink -Value $GitHubProfilePath
}