<#
.SYNOPSIS
    Riepiloga la dimensione di tutti i database su un'istanza SQL Server.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$PercorsoCSV = "C:\Report\SpazioDatabaseSQL.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT d.name AS NomeDatabase,
       CAST(SUM(mf.size) * 8.0 / 1024 AS DECIMAL(10,2)) AS DimensioneMB
FROM sys.master_files mf
JOIN sys.databases d ON d.database_id = mf.database_id
GROUP BY d.name
ORDER BY DimensioneMB DESC
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportata la dimensione di $($risultati.Count) database." -ForegroundColor Green
