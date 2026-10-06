<#
.SYNOPSIS
    Individua le query con tempo medio di esecuzione più alto sull'istanza.
#>
param(
    [string]$ServerSQL = "localhost",
    [int]$Top = 20,
    [string]$PercorsoCSV = "C:\Report\QueryLente.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT TOP $Top
    qs.total_elapsed_time / qs.execution_count / 1000.0 AS MsMedioEsecuzione,
    qs.execution_count AS NumeroEsecuzioni,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1) AS TestoQuery
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY MsMedioEsecuzione DESC
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportate le $Top query piu lente in: $PercorsoCSV" -ForegroundColor Green
