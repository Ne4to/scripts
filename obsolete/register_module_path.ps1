# Doesn't work until the following issue is fixed https://github.com/PowerShell/PowerShell/issues/6850
$MyModulesPath = 'C:\scripts\modules'

function Add-PathItemIfNotExist {
    param (
        [string]$PathValue,
        [string]$PathItem
    )

    $existingItems = $PathValue -split ';'
    if ($existingItems -notcontains $PathItem) {
        $NewValue = ($existingItems + $PathItem) -join ';'
        return @{Modified = $true; NewValue = $NewValue}
    }

    return @{Modified = $false; NewValue = $PathValue}
}

$currentValue = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
$addResult = Add-PathItemIfNotExist -PathValue $currentValue -PathItem $MyModulesPath
if ($addResult.Modified) {
    [Environment]::SetEnvironmentVariable("PSModulePath", $addResult.NewValue, "Machine")
}

$currentValue = $env:PSModulePath
$addResult = Add-PathItemIfNotExist -PathValue $currentValue -PathItem $MyModulesPath
if ($addResult.Modified) {
    $env:PSModulePath = $addResult.NewValue
}