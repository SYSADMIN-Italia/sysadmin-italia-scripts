<#
.SYNOPSIS
    Verifica lo stato dei nodi e delle risorse di un cluster failover Windows Server.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$NomeCluster
)

Import-Module FailoverClusters

Write-Host "=== Nodi del cluster $NomeCluster ===" -ForegroundColor Cyan
$nodi = Get-ClusterNode -Cluster $NomeCluster
foreach ($n in $nodi) {
    $colore = if ($n.State -eq "Up") {"Green"} else {"Red"}
    Write-Host ("{0,-20}: {1}" -f $n.Name, $n.State) -ForegroundColor $colore
}

Write-Host "`n=== Risorse del cluster ===" -ForegroundColor Cyan
$risorse = Get-ClusterResource -Cluster $NomeCluster
$nonOnline = $risorse | Where-Object { $_.State -ne "Online" }

if ($nonOnline) {
    foreach ($r in $nonOnline) {
        Write-Host ("{0,-30}: {1}" -f $r.Name, $r.State) -ForegroundColor Red
    }
} else {
    Write-Host "Tutte le risorse sono online." -ForegroundColor Green
}
