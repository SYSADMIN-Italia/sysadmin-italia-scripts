<#
.SYNOPSIS
    Verifica la percentuale di utilizzo del log delle transazioni per ogni database.
#>
param(
    [string]$ServerSQL = "localhost",
    [int]$SogliaPercentoUso = 80,
    [string]$PercorsoCSV = "C:\Report\SpazioLogTransazioni.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT DB_NAME(database_id) AS NomeDatabase,
       total_log_size_in_bytes / 1024.0 / 1024 AS DimensioneLogMB,
       used_log_space_in_percent AS PercentualeUso
FROM sys.dm_db_log_space_usage
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$allarme = $risultati | Where-Object { $_.PercentualeUso -ge $SogliaPercentoUso }

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Controllati $($risultati.Count) log. Sopra soglia: $($allarme.Count)" -ForegroundColor $(if($allarme.Count -gt 0){"Red"}else{"Green"})
