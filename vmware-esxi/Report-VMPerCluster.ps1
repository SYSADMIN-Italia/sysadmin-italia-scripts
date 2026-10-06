<#
.SYNOPSIS
    Riepiloga il numero di VM per cluster, con conteggio di accese/spente e stato host.
#>
param(
    [string]$PercorsoCSV = "C:\Report\VMPerCluster.csv"
)

$cluster = Get-Cluster

$risultati = foreach ($c in $cluster) {
    $vm = $c | Get-VM
    $host_cluster = $c | Get-VMHost

    [PSCustomObject]@{
        Cluster       = $c.Name
        VMTotali      = $vm.Count
        VMAccese      = ($vm | Where-Object {$_.PowerState -eq "PoweredOn"}).Count
        VMSpente      = ($vm | Where-Object {$_.PowerState -eq "PoweredOff"}).Count
        HostTotali    = $host_cluster.Count
        HostConnessi  = ($host_cluster | Where-Object {$_.ConnectionState -eq "Connected"}).Count
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Riepilogo generato per $($cluster.Count) cluster." -ForegroundColor Green
