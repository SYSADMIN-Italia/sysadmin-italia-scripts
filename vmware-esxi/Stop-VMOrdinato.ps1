<#
.SYNOPSIS
    Spegne le macchine virtuali in un ordine di priorità configurato (scenario down UPS).
#>
param(
    [Parameter(Mandatory=$true)]
    [string[]]$NomiVM,
    [int]$SecondiAttesa = 30
)

foreach ($nomeVM in $NomiVM) {
    $vm = Get-VM -Name $nomeVM -ErrorAction SilentlyContinue

    if (-not $vm) {
        Write-Host "VM '$nomeVM' non trovata, salto." -ForegroundColor Yellow
        continue
    }

    if ($vm.PowerState -eq "PoweredOff") {
        Write-Host "VM '$nomeVM' già spenta, salto." -ForegroundColor Gray
        continue
    }

    Write-Host "Spegnimento ordinato di '$nomeVM' in corso..." -ForegroundColor Cyan
    try {
        Shutdown-VMGuest -VM $vm -Confirm:$false -ErrorAction Stop
    }
    catch {
        Write-Host "Shutdown del sistema operativo non disponibile per '$nomeVM', spegnimento forzato." -ForegroundColor Yellow
        Stop-VM -VM $vm -Confirm:$false
    }

    Start-Sleep -Seconds $SecondiAttesa
}

Write-Host "Sequenza di spegnimento completata." -ForegroundColor Green
