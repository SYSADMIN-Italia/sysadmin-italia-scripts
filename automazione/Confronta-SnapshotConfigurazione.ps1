<#
.SYNOPSIS
    Confronta due file di configurazione esportati in momenti diversi, evidenziando le differenze.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$FileVecchio,
    [Parameter(Mandatory=$true)]
    [string]$FileNuovo,
    [string]$PercorsoReport = "C:\Report\ConfrontoConfigurazione.txt"
)

if (-not (Test-Path $FileVecchio) -or -not (Test-Path $FileNuovo)) {
    Write-Host "Uno dei due file specificati non esiste." -ForegroundColor Red
    return
}

$differenze = Compare-Object -ReferenceObject (Get-Content $FileVecchio) -DifferenceObject (Get-Content $FileNuovo)

$report = foreach ($d in $differenze) {
    if ($d.SideIndicator -eq "=>") {
        "[AGGIUNTO]  $($d.InputObject)"
    } else {
        "[RIMOSSO]   $($d.InputObject)"
    }
}

$report | Out-File -FilePath $PercorsoReport -Encoding UTF8

if ($report) {
    Write-Host "Trovate $($report.Count) differenze tra i due snapshot. Dettaglio in: $PercorsoReport" -ForegroundColor Yellow
} else {
    Write-Host "Nessuna differenza rilevata tra i due snapshot." -ForegroundColor Green
}
