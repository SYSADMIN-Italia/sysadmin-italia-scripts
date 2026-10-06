<#
.SYNOPSIS
    Esporta la tabella di routing IPv4 del sistema locale.
#>
param(
    [string]$PercorsoCSV = "C:\Report\TabellaRouting.csv"
)

$rotte = Get-NetRoute -AddressFamily IPv4

$risultati = $rotte | Select-Object DestinationPrefix, NextHop,
    @{N="Interfaccia";E={(Get-NetAdapter -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue).Name}},
    RouteMetric, Protocol

$risultati | Sort-Object DestinationPrefix | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportate $($risultati.Count) rotte in: $PercorsoCSV" -ForegroundColor Green
