<#
.SYNOPSIS
    Esegue DBCC CHECKDB su un database e registra l'esito in un log.
#>
param(
    [string]$ServerSQL = "localhost",
    [Parameter(Mandatory=$true)]
    [string]$NomeDatabase,
    [string]$LogPath = "C:\Report\IntegritaDatabase_Log.txt"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

Write-Host "Esecuzione DBCC CHECKDB su '$NomeDatabase' in corso, puo richiedere tempo su database di grandi dimensioni..." -ForegroundColor Cyan

try {
    $risultato = Invoke-Sqlcmd -ServerInstance $ServerSQL -Database $NomeDatabase -Query "DBCC CHECKDB WITH NO_INFOMSGS, ALL_ERRORMSGS" -QueryTimeout 0 -ErrorAction Stop
    "$(Get-Date) - CHECKDB completato senza errori su $NomeDatabase" | Out-File -FilePath $LogPath -Append
    Write-Host "Nessun errore di integrita rilevato." -ForegroundColor Green
}
catch {
    "$(Get-Date) - ERRORI rilevati su $NomeDatabase : $_" | Out-File -FilePath $LogPath -Append
    Write-Host "[ATTENZIONE] Rilevati errori di integrita. Dettagli in: $LogPath" -ForegroundColor Red
}
