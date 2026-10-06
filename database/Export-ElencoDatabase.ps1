<#
.SYNOPSIS
    Esporta un inventario di tutti i database dell'istanza con stato e dettagli.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$PercorsoCSV = "C:\Report\ElencoDatabase.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT name AS NomeDatabase, create_date AS DataCreazione,
       state_desc AS Stato, compatibility_level AS LivelloCompatibilita
FROM sys.databases
ORDER BY name
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportati $($risultati.Count) database in: $PercorsoCSV" -ForegroundColor Green
