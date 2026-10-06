<#
.SYNOPSIS
    Individua gli account attivi che non hanno alcuna licenza Microsoft 365 assegnata.
#>
param(
    [string]$PercorsoCSV = "C:\Report\UtentiSenzaLicenza.csv"
)

Import-Module Microsoft.Graph.Users
Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

$utenti = Get-MgUser -All -Filter "accountEnabled eq true" -Property DisplayName, UserPrincipalName, AssignedLicenses

$risultati = $utenti | Where-Object { $_.AssignedLicenses.Count -eq 0 } |
    Select-Object DisplayName, UserPrincipalName

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) utenti attivi senza licenza assegnata." -ForegroundColor Yellow
