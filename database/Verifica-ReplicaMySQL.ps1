<#
.SYNOPSIS
    Verifica lo stato dei thread di replica e il ritardo dal master su un server MySQL slave.
.NOTES
    Richiede il client a riga di comando "mysql" installato e raggiungibile nel PATH.
#>
param(
    [string]$ServerMySQL = "localhost",
    [string]$Utente = "root",
    [string]$Password
)

$risultatoGrezzo = & mysql -h $ServerMySQL -u $Utente -p"$Password" -e "SHOW SLAVE STATUS\G" 2>$null

if (-not $risultatoGrezzo) {
    Write-Host "Nessuna configurazione di replica (slave) trovata su questo server." -ForegroundColor Cyan
    return
}

$ioRunning = ($risultatoGrezzo | Select-String "Slave_IO_Running:") -replace ".*: ", ""
$sqlRunning = ($risultatoGrezzo | Select-String "Slave_SQL_Running:") -replace ".*: ", ""
$secondsBehind = ($risultatoGrezzo | Select-String "Seconds_Behind_Master:") -replace ".*: ", ""

Write-Host "Slave_IO_Running: $ioRunning" -ForegroundColor $(if($ioRunning -eq "Yes"){"Green"}else{"Red"})
Write-Host "Slave_SQL_Running: $sqlRunning" -ForegroundColor $(if($sqlRunning -eq "Yes"){"Green"}else{"Red"})
Write-Host "Secondi di ritardo dal master: $secondsBehind" -ForegroundColor $(if([int]$secondsBehind -gt 60){"Yellow"}else{"Green"})
