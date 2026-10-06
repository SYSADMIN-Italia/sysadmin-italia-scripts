<#
.SYNOPSIS
    Esporta un inventario completo di tutte le macchine virtuali con le specifiche principali.
#>
param(
    [string]$PercorsoCSV = "C:\Report\InventarioVM.csv"
)

$vm = Get-VM

$risultati = $vm | Select-Object Name,
    @{N="vCPU";E={$_.NumCpu}},
    @{N="RAM_GB";E={$_.MemoryGB}},
    @{N="StorageProvisionedGB";E={[math]::Round($_.ProvisionedSpaceGB, 1)}},
    @{N="Host";E={$_.VMHost.Name}},
    @{N="Cluster";E={($_.VMHost | Get-Cluster).Name}},
    PowerState,
    @{N="SistemaOperativo";E={$_.Guest.OSFullName}}

$risultati | Sort-Object Name | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportate $($risultati.Count) VM in: $PercorsoCSV" -ForegroundColor Green
