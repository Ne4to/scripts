Set-StrictMode -Version 'Latest'

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

function Update-GitRepository {
    [CmdletBinding()]
    param (
        [parameter()]
        [UInt32]$Depth = 1,
        [switch]$ShowLog
    )

    $env:LC_ALL='C.UTF-8'
    $SavedInformationPreference = $InformationPreference

    if ($ShowLog) {
        $InformationPreference = 'Continue'
    }

    $gitFullPath = (Get-Command -CommandType Application git -ErrorAction Stop).Source

    Push-Location

    try {
        $RepositoryCollection = Get-ChildItem -Include ".git" -Recurse -Depth $Depth -Directory -Attributes Hidden

        for ($repositoryIndex = 0; $repositoryIndex -lt $RepositoryCollection.length; $repositoryIndex++) {
            $repository = $RepositoryCollection[$repositoryIndex]
            $repositoryPath = $repository.Parent.FullName

            Write-Progress -Activity "Processing git pull" -Status "Repository ($repositoryPath)" -PercentComplete ($repositoryIndex * 100 / $RepositoryCollection.length)
            Write-Information "Processing $repositoryPath"

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

Export-ModuleMember -Function Get-GitRepositoryModifiedFiles
Export-ModuleMember -Function Update-GitRepository