$extensionCollection = @(
    @{
        Name = "PowerShell"
        Id   = "ms-vscode.powershell"
    },
    @{
        Name = "Bracket Pair Colorizer 2"
        Id   = "coenraads.bracket-pair-colorizer-2"
    },
    @{
        Name = "C#"
        Id   = "ms-vscode.csharp"
    },
    @{
        Name = "Code Spell Checker"
        Id   = "streetsidesoftware.code-spell-checker"
    },
    @{
        Name = "Code Time"
        Id   = "softwaredotcom.swdc-vscode"
    },
    @{
        Name = "GitLens — Git supercharged"
        Id   = "eamodio.gitlens"
    },
    @{
        Name = "Docker"
        Id   = "peterjausovec.vscode-docker"
    },
    @{
        Name = "Kubernetes"
        Id   = "ms-kubernetes-tools.vscode-kubernetes-tools"
    },
    @{
        Name = "RAML"
        Id   = "blzjns.vscode-raml"
    },
    @{
        Name = "Ionide-fsharp"
        Id   = "ionide.ionide-fsharp"
    },
    @{
        Name = "YAML"
        Id   = "redhat.vscode-yaml"
    },
    @{
        Name = "Markdown All in One"
        Id = "yzhang.markdown-all-in-one"
    },
    @{
        Name = "VS Live Share"
        Id = "ms-vsliveshare.vsliveshare"
    },
    @{
        Name = "Visual Studio IntelliCode - Preview"
        Id = "visualstudioexptteam.vscodeintellicode"
    },
    @{
        Name = "Cake"
        Id = "cake-build.cake-vscode"
    },
    @{
        Name = "Excel Viewer"
        Id = "grapecity.gc-excelviewer"
    },
    @{
        Name = "Icons for Visual Studio Code"
        Id = "vscode-icons-team.vscode-icons"
    },
    @{
        Name = "C/C++ IntelliSense, debugging, and code browsing."
        Id = "ms-vscode.cpptools"
    },
    @{
        Name = "Port of IntelliJ IDEA Keybindings, including for WebStorm, PyCharm, PHP Storm, etc."
        Id = "k--kato.intellij-idea-keybindings"
    },
    @{
        Name = "Markdown linting and style checking for Visual Studio Code"
        Id = "DavidAnson.vscode-markdownlint"
    },
    @{
        Name = "Remote Development"
        Id = "ms-vscode-remote.vscode-remote-extensionpack"
    }


    # @{
    #     Name = "REST Client"
    #     Id   = "humao.rest-client"
    # },
    # @{
    #     Name = "SQL Server (mssql)"
    #     Id   = "ms-mssql.mssql"
    # },
    # @{
    #     Name = "XML Tools"
    #     Id   = "dotjoshjohnson.xml"
    # }
)

$codeFullPath = (Get-Command code).Source
# $codeFullPath = "C:\Users\sosni\AppData\Local\Programs\Microsoft VS Code\Code.exe"

for ($extensionIndex = 0; $extensionIndex -lt $extensionCollection.length; $extensionIndex++) {
    $extension = $extensionCollection[$extensionIndex]

    Write-Progress -Activity "Installing VS Code extensions" -Status "$($extension.Name) ($($extension.Id))" -PercentComplete ($extensionIndex * 100 / $extensionCollection.length)
    # Write-Output "[$($extensionIndex+1)/$($extensionCollection.length)] $($extension.Name) ($($extension.Id))"

    # & code --install-extension $extension.Id
    # Start-Process code "--install-extension", $extension.Id -NoNewWindow -Wait

    Start-ProcessWithOutputStreaming -FilePath $codeFullPath -ArgumentList "--install-extension", $extension.Id -InformationAction Continue | Out-Null
}
