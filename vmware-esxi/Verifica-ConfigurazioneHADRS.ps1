<#
.SYNOPSIS
    Verifica lo stato di attivazione e configurazione di HA e DRS su ciascun cluster.
#>
param(
    [string]$PercorsoCSV = "C:\Report\ConfigurazioneHADRS.csv"
)

$cluster = Get-Cluster

$risultati = $cluster | Select-Object Name,
    @{N="HAAttivo";E={$_.HAEnabled}},
    @{N="DRSAttivo";E={$_.DrsEnabled}},
    @{N="DRSAutomazione";E={$_.DrsAutomationLevel}},
    @{N="NumeroHost";E={($_ | Get-VMHost).Count}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$problemi = ($risultati | Where-Object {-not $_.HAAttivo -or -not $_.DRSAttivo}).Count
Write-Host "Controllati $($cluster.Count) cluster. Con HA o DRS disattivato: $problemi" -ForegroundColor $(if($problemi -gt 0){"Red"}else{"Green"})
