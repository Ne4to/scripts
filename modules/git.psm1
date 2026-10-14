#Requires -Version 7
Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'

function Get-GitRepositoryModifiedFiles {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]
        $RepositoryPath
        # TODO add [switch]$FullPath or (FullPath | Relative[ToGitRootPath])
    )

    $env:LC_ALL='C.UTF-8'

    $gitFullPath = (Get-Command -CommandType Application git -ErrorAction Stop).Source
    $gitOutput = Start-ProcessWithOutput -FilePath $gitFullPath -ArgumentList "-C",$RepositoryPath,"status","--porcelain"

    # if ($gitOutput.ExitCode -ne 0) {

    # }

    $gitOutput.StandardOutput -split '\n' |
        Where-Object {
            $_ -ne $null -and $_ -ne ''
        } |
        ForEach-Object {
            $sourcePath = $null
            $targetPath = $null

            $path = $_.Substring(3)
            $pathParts = $path -split ' -> '
            $sourcePath = $pathParts[0]

            if ($pathParts.Count -eq 2) {
                $targetPath = $pathParts[1]
            }

            @{
                XFlag = $_[0]
                YFlag = $_[1]
                SourcePath = $sourcePath
                TargetPath = $targetPath
            }
        } |
        ForEach-Object {
            # TODO parse flags
            # TODO paths are relative if command executed not in git root

            if ($_.XFlag -eq '?' -and $_.YFlag -eq '?' -and $_.SourcePath.EndsWith('/')) {
                $FullPath = Join-Path $RepositoryPath $_.SourcePath
                # Write-Warning $FullPath
                Get-ChildItem -Recurse -File $FullPath |
                    ForEach-Object {
                        Write-Output $_.FullName.Substring($RepositoryPath.Length)
                    }
            }

            if ($_.TargetPath) {
                $_.TargetPath
            } else {
                $_.SourcePath
            }
        } |
        Where-Object { $_.EndsWith(".raml") } | # TODO move to IncludeFilter Parameter
        Where-Object { -not $_.EndsWith(".Types.raml") } #| # TODO move to ExcludeFilter Parameter
        #Write-Output

    # file:///C:/Program%20Files/Git/mingw64/share/doc/git-doc/git-status.html
}

function Get-GitRepositories {
    [CmdletBinding()]
    param (
        [parameter()]
        [UInt32]$Depth = 1,
        [parameter()]
        [string]$BasePath = $(Get-Location)
    )

    $env:LC_ALL='C.UTF-8'

    Get-ChildItem -Path $BasePath -Include ".git" -Recurse -Depth $Depth -Directory -Attributes Hidden |
        ForEach-Object {
            $Path = $_.Parent.FullName
            Push-Location $Path
            $DefaultBranch = Get-GitDefaultBranch
            Pop-Location

            [PSCustomObject]@{
                Path = $Path
                Name = $Path.Substring($BasePath.Length + 1) # +1 for `\`
                DefaultBranch = $DefaultBranch
            }
        }
}

function Get-GitDefaultBranch {
    return ((git rev-parse --abbrev-ref origin/HEAD) -split "/")[1]
}

function Update-GitRepository {
    [CmdletBinding()]
    param (
        [parameter()]
        [UInt32]$Depth = 1,
        [switch]$ShowLog,
        [switch]$UseDefaultBranch
    )

    $env:LC_ALL='C.UTF-8'
    $SavedInformationPreference = $InformationPreference

    if ($ShowLog) {
        $InformationPreference = 'Continue'
    }

    $gitFullPath = (Get-Command -CommandType Application git -ErrorAction Stop).Source

    Push-Location

    try {
        Get-GitRepositories -Depth $Depth |
            ForEach-Object {
                $repositoryPath = $_.Path
                $Name = $_.Name

                Write-Progress -Activity "Processing git pull" -Status "Repository ($Name)"
                Write-Information "Processing $Name"

                if ($UseDefaultBranch) {
                    Push-Location $repositoryPath
                    $DefaultBranch = Get-GitDefaultBranch
                    Pop-Location
                    Write-Information "Using branch $DefaultBranch"
                    $CheckoutArguments = @("checkout", $DefaultBranch)
                    Start-ProcessWithOutputStreaming -FilePath $gitFullPath -ArgumentList $CheckoutArguments -WorkingDirectory $repositoryPath | Out-Null
                }
                Start-ProcessWithOutputStreaming -FilePath $gitFullPath -ArgumentList "pull","--progress" -WorkingDirectory $repositoryPath | Out-Null
            }
    }
    finally {
        Pop-Location

        if ($ShowLog) {
            $InformationPreference = $SavedInformationPreference
        }
    }
}

function Get-GitRepositoryOrigin {
    [CmdletBinding()]
    param (
        [parameter()]
        [UInt32]$Depth = 1
    )

    $env:LC_ALL='C.UTF-8'
    $gitFullPath = (Get-Command -CommandType Application git -ErrorAction Stop).Source

    Push-Location

    try {
        Get-GitRepositories -Depth $Depth |
            ForEach-Object {
                $repositoryPath = $_.Path
                $Name = $_.Name

                Write-Progress -Activity "Processing" -Status "Repository ($Name)"
                Write-Information "Processing $Name"

                $process = Start-ProcessWithOutput -FilePath $gitFullPath -ArgumentList "config","--get","remote.origin.url" -WorkingDirectory $repositoryPath
                [PSCustomObject]@{
                    Name = $Name
                    Path = $repositoryPath
                    Origin = $process.StandardOutput
                }
            }
    }
    finally {
        Pop-Location
    }
}

function Get-GitRepositoryStatus {
    [CmdletBinding()]
    param (
        [parameter()]
        [UInt32]$Depth = 1
    )
    # https://stackoverflow.com/questions/20433867/git-ahead-behind-info-between-master-and-branch
    # > git rev-list --left-right --count master...origin/master
    # 0       1
    # This output means: "Compared to master, origin/master is 0 commit ahead and 1 commits behind."

    $env:LC_ALL='C.UTF-8'
    $gitFullPath = (Get-Command -CommandType Application git -ErrorAction Stop).Source
    Push-Location

    try {
        Get-GitRepositories -Depth $Depth |
            ForEach-Object {
                $repositoryPath = $_.Path
                $Name = $_.Name

                Write-Progress -Activity "Processing" -Status "Repository ($Name)"
                Write-Information "Processing $Name"

                $currentBranch = (Start-ProcessWithOutput -FilePath $gitFullPath -ArgumentList "branch","--show-current" -WorkingDirectory $repositoryPath).StandardOutput
                # $process = Start-ProcessWithOutput -FilePath $gitFullPath -ArgumentList "config","--get","remote.origin.url" -WorkingDirectory $repositoryPath
                [PSCustomObject]@{
                    Name = $Name
                    Path = $repositoryPath
                    Branch = $currentBranch
                    # Origin = $process.StandardOutput
                }
            }
    }
    finally {
        Pop-Location
    }
}

function Get-GitMergedBranches {
    $DefaultBranch = Get-GitDefaultBranch
    $IgnoreBranches = @($DefaultBranch, "release-$DefaultBranch")
    $LocalBranches = git for-each-ref --format='%(refname:short)' refs/heads
    $Result = @()
    foreach ($Branch in $LocalBranches) {
        if ($Branch -in $IgnoreBranches) { continue }
        Write-Host "Checking branch $Branch"
        $BranchVerbose = git branch -vv --list $Branch
        $IsBranchGone = $BranchVerbose -like '*: gone]*'
        if ($IsBranchGone) {
            Write-Host "$Branch is gone" -ForegroundColor Yellow
            $Result += $Branch
            continue
        }
        $BranchCommitId = git log $Branch --oneline --max-count=1 --format=%h
        $BranchCommitMessage = git log $Branch --oneline --max-count=1 --format=%s
        $BranchCommitDate = git log $Branch --oneline --max-count=1 --date=iso-strict --format=%ad
        Write-Host "Last commit $BranchCommitId $BranchCommitMessage"

        $DefaultBranchCandidates = git log --reverse --oneline --format=%h --since-as-filter=$BranchCommitDate
        if (-not $DefaultBranchCandidates) {
            Write-Host "no commit candidates found in $DefaultBranch branch"
        }

        foreach($CandidateId in $DefaultBranchCandidates) {
            Write-Host "Checking candidate commit $CandidateId"
            $Diff = git diff --shortstat "$BranchCommitId..$CandidateId"
            if (-not $Diff) {
                Write-Host -ForegroundColor Green "Found merge commit $CandidateId"
                $Result += $Branch
                break
            }
        }
    }

    return $Result
}

function Remove-GitMergedBranches {
    $AllBranches = @(Get-GitMergedBranches)
    foreach ($Branch in $AllBranches) {
        $BranchCommitMessage = git log $Branch --oneline --max-count=1 --format=%s
        $BranchCommitDate = git log $Branch --oneline --max-count=1 --date=iso-strict --format=%ad
        $BranchCommitAuthor = git log $Branch --oneline --max-count=1 --date=iso-strict --format=%an
        $BranchVerbose = git branch -vv --list $Branch
        $IsBranchGone = $BranchVerbose -like '*: gone]*'

        $response = Read-Host "$BranchCommitDate`n$BranchCommitAuthor`n$BranchCommitMessage`nGone: $IsBranchGone`nDelete $Branch branch? (y/n)"
        if ($response -eq "y") {
            git branch -D $Branch
        }
    }

    # TODO "C:\Program Files\Git\bin\git.exe" -c fetch.parallel=0 -c submodule.fetchjobs=0 fetch --progress "--all" --prune --force
}

function Open-GitExtensions {
    Start-Process gite.exe -ArgumentList 'openrepo','.' -NoNewWindow
}

Set-Alias -Name gite -Value Open-GitExtensions

Export-ModuleMember -Function Get-GitRepositoryModifiedFiles
Export-ModuleMember -Function Get-GitRepositories
Export-ModuleMember -Function Get-GitDefaultBranch
Export-ModuleMember -Function Update-GitRepository
Export-ModuleMember -Function Get-GitRepositoryOrigin
Export-ModuleMember -Function Get-GitRepositoryStatus
Export-ModuleMember -Function Get-GitMergedBranches
Export-ModuleMember -Function Remove-GitMergedBranches
Export-ModuleMember -Function Open-GitExtensions -Alias gite