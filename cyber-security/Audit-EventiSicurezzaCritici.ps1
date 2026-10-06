<#
.SYNOPSIS
    Estrae dal log di sicurezza gli eventi corrispondenti a Event ID considerati critici per un audit.
#>
param(
    [int]$OreIndietro = 24,
    [string]$PercorsoCSV = "C:\Report\EventiSicurezzaCritici.csv"
)

# Event ID monitorati: 4720=creazione utente, 4726=eliminazione utente,
# 4728/4732/4756=aggiunta membro a gruppo privilegiato, 1102=log di audit cancellato,
# 4740=account bloccato, 4767=account sbloccato
$eventIdCritici = @(4720, 4726, 4728, 4732, 4756, 1102, 4740, 4767)

$dataLimite = (Get-Date).AddHours(-$OreIndietro)

$eventi = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=$eventIdCritici; StartTime=$dataLimite} -ErrorAction SilentlyContinue

$risultati = $eventi | Select-Object TimeCreated, Id,
    @{N="Descrizione";E={$_.Message.Split("`n")[0]}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) eventi critici nelle ultime $OreIndietro ore." -ForegroundColor $(if($risultati.Count -gt 0){"Yellow"}else{"Green"})
