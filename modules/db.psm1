Set-StrictMode -Version 'Latest'

$psql = 'C:\Program Files\PostgreSQL\16\bin\psql.exe'

function Remove-PostgreDb {
    [CmdletBinding()]
    param (
        $DbName,
        [SecureString]$Password
    )

    $PassPlain = ConvertFrom-SecureString $Password -AsPlainText
    . $psql --command="drop database if exists $DbName with(force);" "host=localhost user=postgres password=$PassPlain port=45010"
}

function New-PostgreDb {
    [CmdletBinding()]
    param (
        $DbName,
        [SecureString]$Password
    )

    $PassPlain = ConvertFrom-SecureString $Password -AsPlainText
    . $psql --command="create database $DbName;" "host=localhost user=postgres password=$PassPlain port=45010"
}

Export-ModuleMember -Function Remove-PostgreDb
Export-ModuleMember -Function New-PostgreDb