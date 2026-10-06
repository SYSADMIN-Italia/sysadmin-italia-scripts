<#
.SYNOPSIS
    Individua account con delega Kerberos non vincolata, configurazione ad alto rischio.
#>
param(
    [string]$PercorsoCSV = "C:\Report\DelegaNonVincolata.csv"
)

Import-Module ActiveDirectory

$utenti = Get-ADUser -Filter {TrustedForDelegation -eq $true} -Properties TrustedForDelegation, DisplayName
$computer = Get-ADComputer -Filter {TrustedForDelegation -eq $true} -Properties TrustedForDelegation

$risultati = @()
$risultati += $utenti | Select-Object @{N="Nome";E={$_.DisplayName}}, @{N="Tipo";E={"Utente"}}, SamAccountName
$risultati += $computer | Select-Object @{N="Nome";E={$_.Name}}, @{N="Tipo";E={"Computer"}}, @{N="SamAccountName";E={$_.SamAccountName}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) oggetti con delega non vincolata." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
