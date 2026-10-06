<#
.SYNOPSIS
    Confronta la Local Security Policy corrente con una baseline salvata.
#>
param(
    [switch]$SalvaBaseline,
    [string]$PercorsoBaseline = "C:\Report\LSP_Baseline.inf",
    [string]$PercorsoCorrente = "C:\Report\LSP_Corrente.inf"
)

secedit /export /cfg $PercorsoCorrente | Out-Null

if ($SalvaBaseline) {
    Copy-Item -Path $PercorsoCorrente -Destination $PercorsoBaseline -Force
    Write-Host "Baseline salvata in: $PercorsoBaseline" -ForegroundColor Green
    return
}

if (-not (Test-Path $PercorsoBaseline)) {
    Write-Host "Nessuna baseline trovata. Esegui prima lo script con -SalvaBaseline." -ForegroundColor Red
    return
}

$differenze = Compare-Object -ReferenceObject (Get-Content $PercorsoBaseline) -DifferenceObject (Get-Content $PercorsoCorrente)

if ($differenze) {
    Write-Host "[ATTENZIONE] Rilevate differenze rispetto alla baseline:" -ForegroundColor Red
    $differenze | ForEach-Object {
        $simbolo = if ($_.SideIndicator -eq "=>") {"+ (nuovo)"} else {"- (rimosso/cambiato)"}
        Write-Host "  $simbolo : $($_.InputObject)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Nessuna differenza rispetto alla baseline." -ForegroundColor Green
}
