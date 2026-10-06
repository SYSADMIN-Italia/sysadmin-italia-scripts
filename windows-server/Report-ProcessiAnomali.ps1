<#
.SYNOPSIS
    Individua i processi con consumo di CPU o memoria superiore a soglie configurabili.
#>
param(
    [double]$SogliaMemoriaMB = 1024,
    [double]$SogliaCPUSecondi = 3600,
    [string]$PercorsoCSV = "C:\Report\ProcessiAnomali.csv"
)

$processi = Get-Process

$risultati = $processi | Where-Object {
    ($_.WorkingSet64 / 1MB) -ge $SogliaMemoriaMB -or $_.CPU -ge $SogliaCPUSecondi
} | Select-Object Name, Id,
    @{N="MemoriaMB";E={[math]::Round($_.WorkingSet64 / 1MB, 1)}},
    @{N="CPUSecondi";E={[math]::Round($_.CPU, 0)}}

$risultati | Sort-Object MemoriaMB -Descending | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) processi sopra soglia su $env:COMPUTERNAME." -ForegroundColor Yellow
