<#
.SYNOPSIS
    Testa la raggiungibilità di un elenco di host e produce un report riepilogativo.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaHost,
    [int]$Tentativi = 4,
    [string]$PercorsoCSV = "C:\Report\ConnettivitaMultiHost.csv"
)

$host_elenco = Get-Content -Path $ListaHost

$risultati = foreach ($h in $host_elenco) {
    $test = Test-Connection -ComputerName $h -Count $Tentativi -ErrorAction SilentlyContinue

    if ($test) {
        $persi = $Tentativi - $test.Count
        [PSCustomObject]@{
            Host          = $h
            Raggiungibile = $true
            TempoMedioMs  = [math]::Round(($test.ResponseTime | Measure-Object -Average).Average, 1)
            PacchettiPersi = $persi
            PercentualePersi = [math]::Round(($persi / $Tentativi) * 100, 0)
        }
    } else {
        [PSCustomObject]@{
            Host = $h; Raggiungibile = $false; TempoMedioMs = "N/D"
            PacchettiPersi = $Tentativi; PercentualePersi = 100
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$irraggiungibili = ($risultati | Where-Object {-not $_.Raggiungibile}).Count
Write-Host "Testati $($host_elenco.Count) host. Irraggiungibili: $irraggiungibili" -ForegroundColor $(if($irraggiungibili -gt 0){"Red"}else{"Green"})
