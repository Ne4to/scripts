[CmdletBinding()]
param(
    [switch]$OpenDiffTool
)

$OneDriveConsumer = $env:OneDriveConsumer
$OneDriveCommercial = $env:OneDriveCommercial

if (-Not $OneDriveConsumer -or -Not (Test-Path $OneDriveConsumer)) {
    throw "OneDrive Consumer path $OneDriveConsumer is not found"
}

if (-Not $OneDriveCommercial -or -Not (Test-Path $OneDriveCommercial)) {
    throw "OneDrive Commercial path $OneDriveCommercial is not found"
}

$rclonePath = "rclone.exe"
$rcloneProcess = Start-ProcessWithOutput -FilePath $rclonePath -ArgumentList "check",('"' + "$OneDriveConsumer\portable\scripts"+ '"'),('"' + "$OneDriveCommercial\portable\scripts"+ '"'),"--exclude-from",('"' + "$OneDriveConsumer\portable\scripts\rclone_exclude_list" + '"')

# Write-Host "ExitCode"
# Write-Host $rcloneProcess.ExitCode
# Write-Host "StandardOutput"
# Write-Host $rcloneProcess.StandardOutput
# Write-Host "StandardError"
# Write-Host $rcloneProcess.StandardError

$diffFileCollection = $rcloneProcess.StandardError -split "\n" |
    # Where-Object {$_ -match "ERROR : (.+):"} |
    Select-String -Pattern "ERROR : (?<filepath>.+):" -CaseSensitive |
    ForEach-Object { $_.Matches.Groups | Where-Object Name -eq filepath } |
    ForEach-Object Value

$diffFileCollection |
    ForEach-Object { Write-Warning "file $_ needs to be sync" }

if ($OpenDiffTool) {
    $diffFileCollection |
        # ForEach-Object { & code --diff "$OneDriveConsumer\portable\scripts\$_" "$OneDriveCommercial\portable\scripts\$_" }
        ForEach-Object { & code --diff "$OneDriveCommercial\portable\scripts\$_" "$OneDriveConsumer\portable\scripts\$_" }
}

# "2019/03/07 01:56:07 ERROR : scripts/install_vscode_extensions.ps1: Sizes differ" -cmatch "ERROR : (.+):"
# $res = "2019/03/07 01:56:07 ERROR : scripts/install_vscode_extensions.ps1: Sizes differ" | Select-String -Pattern "ERROR : (.+):" -CaseSensitive -List
# $res = "2019/03/07 01:56:07 ERROR : scripts/install_vscode_extensions.ps1: Sizes differ" | Select-String -Pattern "ERROR : (?<filepath>.+):" -CaseSensitive -List
# $res.Matches.Groups | where Name -eq filepath | Select-Object Value
# | % Value

#& $rclonePath check "$OneDriveConsumer\portable" "$OneDriveCommercial\portable" --exclude-from rclone_exclude_list

# TODO add a parameter to show diff in VS code
# TODO add a parameter to show diff in Code Compare
# code --diff C:\Users\sosni\OneDrive\portable\scripts\install_vscode_extensions.ps1 'C:\Users\sosni\OneDrive - The Recon Group Inc\portable\scripts\install_vscode_extensions.ps1'

# & "C:\Program Files (x86)\Meld\Meld.exe" "$OneDriveConsumer\portable" "$OneDriveCommercial\portable"

# & "C:\Program Files\Devart\Code Compare\CodeCompare.exe" /environment=standalone /sourcecontrol=none "$OneDriveConsumer\portable" "$OneDriveCommercial\portable"