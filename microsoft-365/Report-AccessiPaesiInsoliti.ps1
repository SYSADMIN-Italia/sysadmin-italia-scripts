<#
.SYNOPSIS
    Analizza i log di accesso ed evidenzia connessioni da paesi non abituali.
#>
param(
    [string[]]$PaesiAttesi = @("IT"),
    [int]$OreIndietro = 24,
    [string]$PercorsoCSV = "C:\Report\AccessiInsoliti.csv"
)

Import-Module Microsoft.Graph.Reports
Connect-MgGraph -Scopes "AuditLog.Read.All" -NoWelcome

$dataLimite = (Get-Date).AddHours(-$OreIndietro).ToString("yyyy-MM-ddTHH:mm:ssZ")

$accessi = Get-MgAuditLogSignIn -Filter "createdDateTime ge $dataLimite and status/errorCode eq 0" -All

$risultati = $accessi | Where-Object { $_.Location.CountryOrRegion -notin $PaesiAttesi } |
    Select-Object @{N="Utente";E={$_.UserPrincipalName}},
    @{N="Paese";E={$_.Location.CountryOrRegion}},
    @{N="Citta";E={$_.Location.City}},
    @{N="IP";E={$_.IPAddress}},
    @{N="Orario";E={$_.CreatedDateTime}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) accessi da paesi non attesi nelle ultime $OreIndietro ore." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
