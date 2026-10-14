#Requires -Version 7

[CmdletBinding()]
param(
  [string]$GitlabUrl = "https://gitlab.wildberries.ru/",
  [string]$RootGroup = "findept/investment-platform/core",
  [string]$Token
)

Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'

function Get-GradleVersion ($PropertiesPath) {
    if (!(Test-Path $PropertiesPath)) { return $Null }
    (Select-String -Path $PropertiesPath -Pattern 'gradle-(?<Version>[\d\.]+)-bin.zip').Matches.Groups[1].Value
}

$BranchName = 'gradle-9.2.1_v3'
$CommitMessage = 'update gradle to v9.2.1'
$DockerBuilder = @'
ARG BUILD_IMAGE=harbor.wildberries.ru/docker-hub-proxy/library/gradle:9.2.1-jdk21
FROM $BUILD_IMAGE AS builder
'@

$headers = @{
    'accept' = 'application/json'
    'PRIVATE-TOKEN' = $Token
}

$resultUrls = @()

Push-Location
try {

    Get-GitRepositories -BasePath 'D:\projects\gitlab.wildberries.ru\findept\investment-platform\core'
    | ForEach-Object {
        $RepositoryRoot = $_.Path
        Set-Location $RepositoryRoot
        $CurrentBranch = $(. git branch --show-current)
        $GradleVersion = Get-GradleVersion('gradle/wrapper/gradle-wrapper.properties')

        [PSCustomObject]@{
            Repo = $RepositoryRoot
            Branch = $CurrentBranch
            GradleVersion = $GradleVersion
        }
    } | Format-Table -AutoSize
    exit


    Get-GitRepositories -BasePath 'D:\projects\gitlab.wildberries.ru\findept\investment-platform\core' | ForEach-Object {
        $RepositoryRoot = $_.Path
        Write-Host "processing $RepositoryRoot"
        Set-Location $RepositoryRoot
        $NoGitChanges = [string]::IsNullOrWhiteSpace($(. git status -s))
        if (!$NoGitChanges) {
            Write-Host 'uncommeted changes, skipping' -ForegroundColor DarkYellow
            return
        }

        $Head = $(git symbolic-ref refs/remotes/origin/HEAD)
        $DefaultBranch = $Head.Substring($Head.LastIndexOf('/') + 1)
        Write-Host $DefaultBranch

        # return
        # . git checkout $DefaultBranch
        # . git pull

        $GradleVersion = Get-GradleVersion('gradle/wrapper/gradle-wrapper.properties')
        Write-Host "Gradle version: $GradleVersion"
        if ($GradleVersion -eq '9.2.1') {
            Write-Host "Already updated, skipping" -ForegroundColor DarkYellow
            return
        }
        if ($GradleVersion -ne '9.1.0') {
            Write-Host "Unknowm gradle version $GradleVersion, skipping" -ForegroundColor DarkYellow
            return
        }

        # $CurrentBranch = $(. git branch --show-current)
        # Write-Host "branch: $CurrentBranch"
        . git checkout -b $BranchName $DefaultBranch

        . gradle wrapper --gradle-version 9.2.1
        (Get-Content 'docker/Dockerfile') -replace "FROM harbor.wildberries.ru/docker-hub-proxy/library/gradle:9.1.0-jdk21 as builder", $DockerBuilder |
            Set-Content 'docker/Dockerfile'

        $UpdatedGitlabCI = (select-string -path '.gitlab-ci.yml' -pattern 'CI_TMPL_GRADLE_IMAGE_VERSION' -notmatch).Line
        $UpdatedGitlabCI | Set-Content '.gitlab-ci.yml'

        git add .
        git commit -m $CommitMessage
        git push --set-upstream origin $BranchName

        $ProjectName = $((git config --get remote.origin.url) -replace 'git@gitlab.wildberries.ru:','' -replace '.git','')
        $ProjectNameEncoded = [System.Net.WebUtility]::UrlEncode($ProjectName)
        $ProjectDetails = Invoke-RestMethod -Uri "$GitlabUrl/api/v4/projects/$ProjectNameEncoded" -Headers $headers
        $ProjectId = $ProjectDetails.id
        Write-Host "Project Id: $ProjectId"

        $Form = @{
            source_branch = $BranchName
            target_branch = $DefaultBranch
            title         = $CommitMessage
        }
        $MR = Invoke-RestMethod -Method Post -Uri "$GitlabUrl/api/v4/projects/$ProjectId/merge_requests" -Headers $headers -Form $Form
        Write-Host $MR
        $resultUrls += ($MR.web_url)
        Write-Host "New MR url:  $($MR.web_url)"

        Start-Sleep -Seconds 2
        $PatchForm = @{
            auto_merge = $True
        }
        Invoke-RestMethod -Method Put -Uri "$GitlabUrl/api/v4/projects/$ProjectId/merge_requests/$($MR.iid)/merge" -Headers $headers -Form $PatchForm
        # break
    }
}
finally {
    Pop-Location
    $resultUrls
}