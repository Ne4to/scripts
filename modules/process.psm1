Set-StrictMode -Version 'Latest'

function Start-ProcessWithOutputStreaming {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]$FilePath,
        [string[]]$ArgumentList,
        [string]$WorkingDirectory
    )

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $FilePath
    $pinfo.WorkingDirectory = $WorkingDirectory
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.CreateNoWindow = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $ArgumentList

    $OutputDataReceivedHandler = {
        if ($null -ne $EventArgs.Data) {
            Write-Information $EventArgs.Data
        } else {
            # Write-Information "StandardOutput stream closed"
        }
    }

    $ErrorDataReceivedHandler = {
        if ($null -ne $EventArgs.Data) {
            Write-Warning $EventArgs.Data
        } else {
            # Write-Information "StandardError stream closed"
        }
    }

    $process = New-Object System.Diagnostics.Process
    $process.EnableRaisingEvents = $true
    $process.StartInfo = $pinfo

    $OutputDataReceivedEvent = Register-ObjectEvent -InputObject $process `
        -Action $OutputDataReceivedHandler -EventName 'OutputDataReceived' `

    $ErrorDataReceivedEvent = Register-ObjectEvent -InputObject $process `
        -Action $ErrorDataReceivedHandler -EventName 'ErrorDataReceived' `

    $process.Start() | Out-Null
    $process.BeginOutputReadLine()
    $process.BeginErrorReadLine()

    do {
        Start-Sleep -Milliseconds 50
    } while (!$process.HasExited)

    # $process.CancelOutputRead();
    # $process.CancelErrorRead();
    $process.WaitForExit()

    # Unregistering events to retrieve process output.
    Unregister-Event -SourceIdentifier $OutputDataReceivedEvent.Name
    Unregister-Event -SourceIdentifier $ErrorDataReceivedEvent.Name

    return @{ExitCode = $process.ExitCode}
}

function Start-ProcessWithOutput {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]$FilePath,
        [string[]]$ArgumentList,
        [string]$WorkingDirectory
    )

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $FilePath
    $pinfo.WorkingDirectory = $WorkingDirectory
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.CreateNoWindow = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $ArgumentList

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $pinfo
    $process.Start() | Out-Null

    $standardOutput = $process.StandardOutput.ReadToEnd()
    $standardError = $process.StandardError.ReadToEnd()

    $process.WaitForExit()

    return @{
        ExitCode = $process.ExitCode
        StandardOutput = $standardOutput
        StandardError = $standardError
    }
}

function Get-ProcessStatistics {
    [CmdletBinding()]
    param (
        [int]$MinItemCount = 2,
        [ValidateSet("Count", "ProcessName", "CPU", "PM", "WS")]
        [string]$SortBy = "Count",
        [switch]$Format
    )

    $ProcessStatistics = Get-Process |
        Group-Object ProcessName |
        Where-Object Count -ge $MinItemCount |
        ForEach-Object {
            $GroupStat = @{}

            $_.Group |
                Measure-Object CPU,PM,WS -Sum |
                ForEach-Object {
                    $GroupStat[$_.Property] = $_.Sum
                }

            [PSCustomObject]@{
                Count = $_.Count
                ProcessName = $_.Name
                CPU = $GroupStat["CPU"]
                PM = $GroupStat["PM"]
                WS = $GroupStat["WS"]
            }
        }

    if ($Format) {
        $ProcessStatistics |
            Sort-Object $SortBy -Descending |
            Format-Table `
                Count,
                @{Label = "CPU"; Expression = {[timespan]::FromSeconds($_.CPU).ToString("d\.hh\:mm\:ss")}},
                @{Label = "PM(M)"; Expression = {[int]($_.PM / 1024 / 1024)}},
                @{Label = "WS(M)"; Expression = {[int]($_.WS / 1024 / 1024)}},
                ProcessName -AutoSize
    } else {
        $ProcessStatistics
    }
}

Export-ModuleMember -Function Start-ProcessWithOutputStreaming
Export-ModuleMember -Function Start-ProcessWithOutput
Export-ModuleMember -Function Get-ProcessStatistics