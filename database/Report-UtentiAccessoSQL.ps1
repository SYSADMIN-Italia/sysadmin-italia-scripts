<#
.SYNOPSIS
    Esporta tutti i login configurati su un'istanza SQL Server.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$PercorsoCSV = "C:\Report\UtentiAccessoSQL.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT sp.name AS Login, sp.type_desc AS Tipo, sp.is_disabled AS Disabilitato,
       sp.create_date, sp.default_database_name
FROM sys.server_principals sp
WHERE sp.type IN ('S','U','G')
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportati $($risultati.Count) login dell'istanza." -ForegroundColor Green
