<#
.SYNOPSIS
    Verifica che Windows Server Backup sia configurato e che l'ultimo job sia andato a buon fine.
#>

Import-Module WindowsServerBackup -ErrorAction SilentlyContinue

if (-not (Get-Module WindowsServerBackup)) {
    Write-Host "Il modulo Windows Server Backup non risulta installato su questo server." -ForegroundColor Red
    return
}

try {
    $policy = Get-WBPolicy -ErrorAction Stop
    Write-Host "Pianificazione di backup trovata." -ForegroundColor Green
    Write-Host ($policy | Format-List | Out-String)
}
catch {
    Write-Host "Nessuna pianificazione di backup configurata." -ForegroundColor Yellow
}

$summary = Get-WBSummary

Write-Host "`n=== Riepilogo ultimo backup ===" -ForegroundColor Cyan
Write-Host "Ultimo esito: $($summary.LastBackupResultHR)" -ForegroundColor $(if($summary.LastBackupResultHR -eq 0){"Green"}else{"Red"})
Write-Host "Data ultimo backup: $($summary.LastSuccessfulBackupTime)"
Write-Host "Prossimo backup pianificato: $($summary.NextBackupTime)"
