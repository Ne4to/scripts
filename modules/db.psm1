#Requires -Version 7
Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'

$psql = 'C:\Program Files\PostgreSQL\18\bin\psql.exe'

function Remove-PostgreDb {
    [CmdletBinding()]
    param (
        $DbName,
        [SecureString]$Password
    )

    $PassPlain = ConvertFrom-SecureString $Password -AsPlainText
    & $psql --command="drop database if exists $DbName with(force);" "host=localhost user=postgres password=$PassPlain port=45010"
}

function New-PostgreDb {
    [CmdletBinding()]
    param (
        $DbName,
        [SecureString]$Password
    )

    $PassPlain = ConvertFrom-SecureString $Password -AsPlainText
    & $psql --command="create database $DbName;" "host=localhost user=postgres password=$PassPlain port=45010"
    & $psql --command="CREATE EXTENSION IF NOT EXISTS pgcrypto;" "host=localhost user=postgres password=$PassPlain port=45010 dbname=$DbName"
}

function Update-LiquibaseDb {
    [CmdletBinding()]
    param (
        $DbName,
        [SecureString]$Password,
        $Changelog = "src\main\resources\db\changelog\db.changelog-master.xml"
    )

    $PasswordPlan = ConvertFrom-SecureString -SecureString $Password -AsPlainText
    & liquibase update --changelog-file=$Changelog --url=jdbc:postgresql://localhost:45010/$DbName --username=postgres --password=$PasswordPlan
}

function Reset-DevDb {
    param (
        $DbName,
        [SecureString]$Password
    )

    Remove-PostgreDb -DbName $DbName -Password $Password
    New-PostgreDb -DbName $DbName -Password $Password
    Push-Location
    Set-Location 'D:\projects\gitlab.wildberries.ru\findept\investment-platform\libraries\'
    Update-LiquibaseDb -DbName $DbName -Password $Password -Changelog 'db.changelog-master.xml'
    Pop-Location
    Update-LiquibaseDb -DbName $DbName -Password $Password
}

Export-ModuleMember -Function Remove-PostgreDb
Export-ModuleMember -Function New-PostgreDb
Export-ModuleMember -Function Update-LiquibaseDb
Export-ModuleMember -Function Reset-DevDb