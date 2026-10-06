<#
.SYNOPSIS
    Individua le statistiche di tabella non aggiornate da più della soglia configurata.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$NomeDatabase,
    [int]$GiorniSoglia = 7,
    [string]$PercorsoCSV = "C:\Report\StatisticheObsolete.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT OBJECT_NAME(s.object_id) AS Tabella, s.name AS Statistica,
       STATS_DATE(s.object_id, s.stats_id) AS UltimoAggiornamento
FROM sys.stats s
WHERE STATS_DATE(s.object_id, s.stats_id) < DATEADD(DAY, -$GiorniSoglia, GETDATE())
   OR STATS_DATE(s.object_id, s.stats_id) IS NULL
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Database $NomeDatabase -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) statistiche non aggiornate da oltre $GiorniSoglia giorni." -ForegroundColor Yellow
