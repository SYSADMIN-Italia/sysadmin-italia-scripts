<#
.SYNOPSIS
    Estrae gli eventi di tipo errore registrati su vCenter nelle ultime N ore.
#>
param(
    [int]$OreIndietro = 24,
    [string]$PercorsoCSV = "C:\Report\EventiCriticiVCenter.csv"
)

$dataLimite = (Get-Date).AddHours(-$OreIndietro)

$eventi = Get-VIEvent -Start $dataLimite -Types Error -MaxSamples 500

$risultati = $eventi | Select-Object CreatedTime,
    @{N="Oggetto";E={$_.Vm.Name; if(-not $_.Vm.Name){$_.Host.Name}}},
    FullFormattedMessage

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) eventi di errore nelle ultime $OreIndietro ore." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
