<#
.SYNOPSIS
    Individua gli indici con frammentazione sopra soglia in un database.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$NomeDatabase,
    [int]$SogliaFrammentazionePercento = 30,
    [string]$PercorsoCSV = "C:\Report\IndiciFrammentati.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT OBJECT_NAME(ips.object_id) AS Tabella, i.name AS Indice,
       ips.avg_fragmentation_in_percent AS PercentualeFrammentazione
FROM sys.dm_db_index_physical_stats(DB_ID('$NomeDatabase'), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.avg_fragmentation_in_percent > $SogliaFrammentazionePercento AND i.name IS NOT NULL
ORDER BY PercentualeFrammentazione DESC
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Database $NomeDatabase -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) indici sopra il $SogliaFrammentazionePercento% di frammentazione." -ForegroundColor Yellow
