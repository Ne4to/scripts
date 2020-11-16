Set-StrictMode -Version 'Latest'

[string]$global:KubeConfigPath = $null

function Set-KubeConfig {
    if ($global:KubeConfigPath) { return }

    $global:KubeConfigPath = New-TemporaryFile
    Copy-Item "$Home\.kube\config" $global:KubeConfigPath
    $env:KUBECONFIG = "$global:KubeConfigPath;$Home\.kube\config"
}

function Set-KubectlContext {
    param (
        [string]$Name
    )

    if ($Name) {
        $selection = $Name
    } else {
        # gci ~\.kube\context-* -File
        $contexts = $(kubectl config get-contexts -o name) -split [System.Environment]::NewLine

        $selection = ($contexts | Invoke-Fzf)
    }

    if ($selection) {
        Set-KubeConfig
        kubectl config use-context $selection
    }
}

Set-Alias -Name kubectx -Value Set-KubectlContext

Register-ArgumentCompleter -CommandName Set-KubectlContext -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $(kubectl config get-contexts -o name) -split [System.Environment]::NewLine |
        Where-Object { $_ -like "*$wordToComplete*" } |
        ForEach-Object { $_ }
}

function Set-KubectlNamespace {
    param (
        [string]$Name
    )

    if ($Name) {
        $selection = $Name
    } else {
        $namespaces = $(kubectl get ns -o custom-columns=NAME:.metadata.name --no-headers) -split [System.Environment]::NewLine
        $selection = ($namespaces | Invoke-Fzf)
    }

    if ($selection) {
        Set-KubeConfig
        kubectl config set-context --current --namespace=$selection
    }
}

Set-Alias -Name kubens -Value Set-KubectlNamespace

Register-ArgumentCompleter -CommandName Set-KubectlNamespace -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $(kubectl get ns -o custom-columns=NAME:.metadata.name --no-headers) -split [System.Environment]::NewLine |
        Where-Object { $_ -like "*$wordToComplete*" } |
        ForEach-Object { $_ }
}

function Get-KubectlContext {
    $kubeContext = (kubectl config view --minify -o json | ConvertFrom-Json -AsHashTable)
    if (! $kubeContext) { return $null }

    return @{
        Name      = $kubeContext.'current-context'
        Namespace = $kubeContext.contexts[0].context['namespace'] ?? 'default'
    }
}

Export-ModuleMember -Function Set-KubectlContext, Set-KubectlNamespace, Get-KubectlContext -Alias *
