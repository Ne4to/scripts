Set-StrictMode -Version 'Latest'

function Build-Raml {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]
        $RepositoryPath,

        [parameter(Mandatory = $true)]
        [string]
        $Raml2DotNetPath

        # TODO add move = v1 | v2, default = v2
        # TODO add [switch] Debug
        # TODO add [switch] UI
    )

    Push-Location $env:TEMP

    try {
        [string[]]$raml2DotNetArguments = @()

        if ($Raml2DotNetPath.EndsWith(".dll")) {
            $raml2DotNetArguments += $Raml2DotNetPath
            $Raml2DotNetPath = "dotnet"
        }

        $raml2DotNetArguments += "/optimize"
        $raml2DotNetArguments += "/version-suffix=.437"
        $raml2DotNetArguments += "/contract=" + """" + (Join-Path $RepositoryPath "ramlTranslatorContract.raml") + """"
        # $raml2DotNetArguments += "--debug"

        $ModifiedFiles = Get-GitRepositoryModifiedFiles -RepositoryPath $RepositoryPath
        # if ($ModifiedFiles.Count -eq 0) {
        #     Write-Warning "Nothing to build"
        #     return
        # }

        # TODO filter files contains title & nugetVersion http://teamcity.trgdev.local:8111/admin/editRunType.html?id=buildType:Raml_R1Raml_BuildPackages&runnerId=RUNNER_40&cameFromUrl=%2Fadmin%2FeditBuildRunners.html%3Fid%3DbuildType%253ARaml_R1Raml_BuildPackages%26init%3D1&cameFromTitle=
        $ModifiedFiles |
            ForEach-Object {
                $raml2DotNetArguments += """" + (Join-Path $RepositoryPath $_) + """"
            }

        $raml2DotNetArguments

        # Start-ProcessWithOutputStreaming -FilePath $Raml2DotNetPath -ArgumentList $raml2DotNetArguments
        Start-Process -FilePath $Raml2DotNetPath -ArgumentList $raml2DotNetArguments -Wait
    }
    finally {
        Pop-Location
    }
}

function Invoke-DownloadRaml2DotNet {
    Start-Process "http://teamcity.trgdev.local/repository/downloadAll/Tools_R1Raml2DotNet_BuildV20/.lastSuccessful/artifacts.zip"
}

Export-ModuleMember -Function Build-Raml