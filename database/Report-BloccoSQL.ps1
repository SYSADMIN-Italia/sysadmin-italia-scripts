<#
.SYNOPSIS
    Individua in tempo reale le sessioni bloccate su SQL Server e la sessione bloccante.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$PercorsoCSV = "C:\Report\BloccoSQL.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT blocking_session_id AS SessioneBloccante, session_id AS SessioneBloccata,
       wait_type AS TipoAttesa, wait_time AS AttesaMs, DB_NAME(database_id) AS Database_
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
if ($risultati.Count -gt 0) {
    Write-Host "[ATTENZIONE] Trovate $($risultati.Count) sessioni bloccate." -ForegroundColor Red
} else {
    Write-Host "Nessun blocco attivo rilevato." -ForegroundColor Green
}
