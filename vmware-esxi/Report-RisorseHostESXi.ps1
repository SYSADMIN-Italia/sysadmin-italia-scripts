<#
.SYNOPSIS
    Riepiloga l'utilizzo corrente di CPU e memoria per ciascun host ESXi gestito.
#>
param(
    [string]$PercorsoCSV = "C:\Report\RisorseHostESXi.csv"
)

$host_esxi = Get-VMHost

$risultati = $host_esxi | Select-Object Name,
    @{N="CPU_UsoMHz";E={$_.CpuUsageMhz}},
    @{N="CPU_TotaleMHz";E={$_.CpuTotalMhz}},
    @{N="CPU_PercentualeUso";E={[math]::Round(($_.CpuUsageMhz / $_.CpuTotalMhz) * 100, 1)}},
    @{N="RAM_UsoGB";E={[math]::Round($_.MemoryUsageGB, 1)}},
    @{N="RAM_TotaleGB";E={[math]::Round($_.MemoryTotalGB, 1)}},
    @{N="RAM_PercentualeUso";E={[math]::Round(($_.MemoryUsageGB / $_.MemoryTotalGB) * 100, 1)}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportato l'utilizzo di $($host_esxi.Count) host ESXi in: $PercorsoCSV" -ForegroundColor Green
