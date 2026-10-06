<#
.SYNOPSIS
    Esporta la struttura completa delle Unità Organizzative del dominio, con conteggio oggetti per OU.
#>
param(
    [string]$PercorsoCSV = "C:\Report\StrutturaOU.csv"
)

Import-Module ActiveDirectory

$ou = Get-ADOrganizationalUnit -Filter * -Properties Description

$risultati = foreach ($unit in $ou) {
    $utentiCount = (Get-ADUser -Filter * -SearchBase $unit.DistinguishedName -SearchScope OneLevel -ErrorAction SilentlyContinue).Count
    $computerCount = (Get-ADComputer -Filter * -SearchBase $unit.DistinguishedName -SearchScope OneLevel -ErrorAction SilentlyContinue).Count

    [PSCustomObject]@{
        Nome              = $unit.Name
        PercorsoCompleto  = $unit.DistinguishedName
        Descrizione       = $unit.Description
        UtentiDiretti     = $utentiCount
        ComputerDiretti   = $computerCount
    }
}

$risultati | Sort-Object PercorsoCompleto | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportate $($risultati.Count) Unità Organizzative in: $PercorsoCSV" -ForegroundColor Green
