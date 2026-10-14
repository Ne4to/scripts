#Requires -Version 7

[CmdletBinding()]
param(
  [string]$GitlabUrl = "https://gitlab.wildberries.ru/",
  [string]$RootGroup = "findept/investment-platform/core",
  [string]$Token
)

Set-StrictMode -Version 'Latest'

$RootGroupUri = [uri]::EscapeDataString($RootGroup)

$headers = @{
    'accept' = 'application/json'
    'PRIVATE-TOKEN' = $Token
}

$Groups = Invoke-RestMethod -Uri "$GitlabUrl/api/v4/groups?search=$RootGroupUri" -Headers $headers
# $Groups
$GroupId = $Groups[0].id

$Projects = Invoke-RestMethod -Uri "$GitlabUrl/api/v4/groups/$GroupId/projects?per_page=50" -Headers $headers
$Projects | ForEach-Object {
    $Project = $_
    $ProjectDetails = Invoke-RestMethod -Uri "$GitlabUrl/api/v4/projects/$($Project.id)" -Headers $headers

    [PSCustomObject]@{
        path_with_namespace = $ProjectDetails.path_with_namespace
        remove_source_branch_after_merge = $ProjectDetails.remove_source_branch_after_merge
    }
}