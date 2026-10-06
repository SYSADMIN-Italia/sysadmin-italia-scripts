<#
.SYNOPSIS
    Controlla lo spazio disco disponibile su un elenco di server, segnalando i volumi sotto soglia.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaServer,
    [int]$SogliaAllarmePercento = 15,
    [string]$PercorsoCSV = "C:\Report\SpazioDiscoMultiServer.csv"
)

$server = Get-Content -Path $ListaServer

$risultati = foreach ($srv in $server) {
    try {
        $dischi = Get-CimInstance -ComputerName $srv -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop

        foreach ($d in $dischi) {
            $percentualeLibera = [math]::Round(($d.FreeSpace / $d.Size) * 100, 1)
            [PSCustomObject]@{
                Server            = $srv
                Volume            = $d.DeviceID
                SpazioLiberoGB    = [math]::Round($d.FreeSpace / 1GB, 1)
                SpazioTotaleGB    = [math]::Round($d.Size / 1GB, 1)
                PercentualeLibera = $percentualeLibera
                Allarme           = if ($percentualeLibera -le $SogliaAllarmePercento) {"SI"} else {"NO"}
            }
        }
    }
    catch {
        [PSCustomObject]@{ Server = $srv; Volume = "N/D"; SpazioLiberoGB = "N/D"; SpazioTotaleGB = "N/D"; PercentualeLibera = "N/D"; Allarme = "NON RAGGIUNGIBILE" }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$inAllarme = ($risultati | Where-Object {$_.Allarme -eq "SI"}).Count
Write-Host "Controllati $($server.Count) server. Volumi in allarme: $inAllarme" -ForegroundColor $(if($inAllarme -gt 0){"Red"}else{"Green"})
