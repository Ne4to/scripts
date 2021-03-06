#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    # path
    $sPath = "$(Get-FullPath -dir $pwd) "

    # check for elevated prompt
    If (Test-Administrator) {
        $sAdmin = " $($sl.PromptSymbols.ElevatedSymbol)"
    }

    # git info
    If ($vcsStatus = Get-VCSStatus) {
        $vcsInfo = Get-VcsInfo -status ($vcsStatus)
        $sVcs = "$($vcsInfo.VcInfo) "
    }

    # timestamp
    $sTime = " $(Get-Date -Format HH:mm:ss)"

    # check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $sFailed = " $($sl.PromptSymbols.FailedCommandSymbol)"
    }

    # virtualenv
    If (Test-VirtualEnv) {
        $sVenv = " $(Get-VirtualEnvName)"
    }

    # with
    If ($with) {
        $sWith = " $($with.ToUpper())"
    }
    # cmdDur
    $lastCmd = Get-History -Count 1
    if ($null -ne $lastCmd) {
        $cmdTime = $lastCmd.Duration.TotalMilliseconds
        $units = "ms"
        if ($cmdTime -gt 250 -and $cmdTime -lt 1000) {            
        } elseif ($cmdTime -ge 1000) {
            $units = "s"
            $cmdTime = $lastCmd.Duration.TotalSeconds
            if ($cmdTime -ge 60) {
                $units = "m"
                $cmdTime = $lastCmd.Duration.TotalMinutes
            }
        }

        
        $cmdTime = "$($cmdTime.ToString("#.##"))$units"
    }

    $rightPrompt = "$sFailed$sWith$sVenv$sAdmin$cmdTime$sTime"
    $prompt += Set-CursorForRightBlockWrite -textLength $rightPrompt.Length

    $prompt += Write-Prompt -Object $sFailed -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    $prompt += Write-Prompt -Object $sWith   -ForegroundColor $sl.Colors.WithForegroundColor
    $prompt += Write-Prompt -Object $sVenv   -ForegroundColor $sl.Colors.VirtualEnvForegroundColor
    $prompt += Write-Prompt -Object $sAdmin  -ForegroundColor $sl.Colors.AdminIconForegroundColor
    $prompt += Write-Prompt -Object $cmdTime -ForegroundColor $sl.colors.TimestampForegroundColor
    $prompt += Write-Prompt -Object $sTime   -ForegroundColor $sl.colors.TimestampForegroundColor
    $prompt += Write-Prompt -Object "`r"
    $prompt += Write-Prompt -Object $sPath   -ForegroundColor $sl.Colors.DriveForegroundColor
    $prompt += Write-Prompt -Object $sVcs    -ForegroundColor $vcsInfo.BackgroundColor

    If ($sl.DoubleCommandLine) {
        $prompt += Set-Newline
    }

    # Writes the postfixes to the prompt
    $indicatorColor = If ($lastCommandFailed) { $sl.Colors.CommandFailedIconForegroundColor } Else { $sl.Colors.PromptSymbolColor }
    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $indicatorColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Green
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::Magenta
$sl.Colors.TimestampForegroundColor = [ConsoleColor]::DarkCyan
$sl | Add-Member -NotePropertyName DoubleCommandLine -NotePropertyValue 0
