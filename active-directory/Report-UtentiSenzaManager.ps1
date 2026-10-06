<#
.SYNOPSIS
    Report degli utenti attivi senza il campo "Manager" valorizzato in Active Directory.
#>
param(
    [string]$PercorsoCSV = "C:\Report\UtentiSenzaManager.csv"
)

Import-Module ActiveDirectory

$utenti = Get-ADUser -Filter {Enabled -eq $true} -Properties Manager, DisplayName, Department, Title |
    Where-Object { -not $_.Manager }

$risultati = $utenti | Select-Object DisplayName, SamAccountName, Department, Title

$risultati | Sort-Object Department | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) utenti attivi senza manager assegnato." -ForegroundColor Yellow
