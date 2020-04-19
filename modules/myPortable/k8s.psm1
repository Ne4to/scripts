Set-StrictMode -Version 'Latest'

function Show-Menu {
    param (
        [string]$Title = 'Menu',
        [string[]]$MenuOptions
    )
    Write-Host "================ $Title ================"

    for ($optionIndex = 0; $optionIndex -lt $MenuOptions.Count; $optionIndex++) {
        Write-Host "$($optionIndex + 1): $($MenuOptions[$optionIndex])"
    }

    $selection = Read-Host "Please make a selection"
    return $MenuOptions[$selection - 1]
}

function Build-KubectlContextConfigFiles {
    $contexts = $(kubectl config get-contexts -o name)

    $contexts -split [System.Environment]::NewLine | `
        ForEach-Object {
        Set-Content -Value "current-context: $_" -Path "$Home\.kube\context-$_"
    }
}

function Set-KubectlContext {
    # gci ~\.kube\context-* -File
    $contexts = $(kubectl config get-contexts -o name) -split [System.Environment]::NewLine

    $selection = Show-Menu –Title 'kubectl context' -MenuOptions $contexts
    if ($selection) {
        $env:KUBECONFIG = "$Home\.kube\context-$selection;$Home\.kube\config"
    }
}

Set-Alias -Name kubectx -Value Set-KubectlContext

function Set-KubectlNamespace {
    $namespaces = $(kubectl get ns -o custom-columns=NAME:.metadata.name --no-headers) -split [System.Environment]::NewLine
    $selection = Show-Menu –Title 'kubectl namespace' -MenuOptions $namespaces
    if ($selection) {
        kubectl config set-context --current --namespace=$selection
    }
}

Set-Alias -Name kubens -Value Set-KubectlNamespace

function Get-KubectlContext {
    $kubeContext = (kubectl config view --minify -o json | ConvertFrom-Json -AsHashTable)
    if (! $kubeContext) { return $null }

    return @{
        Name      = $kubeContext.'current-context'
        Namespace = $kubeContext.contexts[0].context['namespace'] ?? 'default'
    }
}

Export-ModuleMember -Function Build-KubectlContextConfigFiles, Set-KubectlContext, Set-KubectlNamespace, Get-KubectlContext -Alias *


