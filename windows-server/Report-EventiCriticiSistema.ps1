<#
.SYNOPSIS
    Estrae dai log System e Application gli eventi di livello Critico o Errore recenti.
#>
param(
    [int]$OreIndietro = 24,
    [string]$PercorsoCSV = "C:\Report\EventiCriticiSistema.csv"
)

$dataLimite = (Get-Date).AddHours(-$OreIndietro)

$eventi = Get-WinEvent -FilterHashtable @{LogName=('System','Application'); Level=(1,2); StartTime=$dataLimite} -ErrorAction SilentlyContinue

$risultati = $eventi | Select-Object TimeCreated, LogName, Id, LevelDisplayName, ProviderName,
    @{N="Messaggio";E={$_.Message.Split("`n")[0]}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) eventi critici/errore nelle ultime $OreIndietro ore." -ForegroundColor $(if($risultati.Count -gt 0){"Yellow"}else{"Green"})
