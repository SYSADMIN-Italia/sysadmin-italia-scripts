<#
.SYNOPSIS
    Misura il traffico medio in entrata e uscita su ciascuna interfaccia di rete attiva.
#>
param(
    [int]$SecondiMisurazione = 30,
    [string]$PercorsoCSV = "C:\Report\UtilizzoBanda.csv"
)

$adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

$primaLettura = Get-NetAdapterStatistics -Name $adapter.Name
Write-Host "Misurazione in corso per $SecondiMisurazione secondi..." -ForegroundColor Cyan
Start-Sleep -Seconds $SecondiMisurazione
$secondaLettura = Get-NetAdapterStatistics -Name $adapter.Name

$risultati = foreach ($a in $adapter) {
    $prima = $primaLettura | Where-Object { $_.Name -eq $a.Name }
    $dopo = $secondaLettura | Where-Object { $_.Name -eq $a.Name }

    $bytesRicevuti = $dopo.ReceivedBytes - $prima.ReceivedBytes
    $bytesInviati = $dopo.SentBytes - $prima.SentBytes

    [PSCustomObject]@{
        Interfaccia   = $a.Name
        RicezioneMbps = [math]::Round(($bytesRicevuti * 8 / $SecondiMisurazione) / 1MB, 2)
        InvioMbps     = [math]::Round(($bytesInviati * 8 / $SecondiMisurazione) / 1MB, 2)
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Misurazione completata su $($adapter.Count) interfacce." -ForegroundColor Green
