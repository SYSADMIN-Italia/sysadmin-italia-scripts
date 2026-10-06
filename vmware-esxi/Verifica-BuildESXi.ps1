<#
.SYNOPSIS
    Verifica versione e build di ESXi su tutti gli host, individuando incoerenze nel cluster.
#>
param(
    [string]$PercorsoCSV = "C:\Report\VersioniESXi.csv"
)

$host_esxi = Get-VMHost

$risultati = $host_esxi | Select-Object Name,
    @{N="Cluster";E={($_ | Get-Cluster).Name}},
    Version, Build

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"

$perCluster = $risultati | Group-Object Cluster
foreach ($c in $perCluster) {
    $versioniUniche = ($c.Group | Select-Object -ExpandProperty Build -Unique).Count
    if ($versioniUniche -gt 1) {
        Write-Host "[ATTENZIONE] Cluster '$($c.Name)' ha host con build ESXi diverse tra loro." -ForegroundColor Red
    }
}
Write-Host "Controllati $($host_esxi.Count) host ESXi." -ForegroundColor Green
