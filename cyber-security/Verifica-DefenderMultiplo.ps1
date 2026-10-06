<#
.SYNOPSIS
    Verifica lo stato di protezione Windows Defender su un elenco di computer remoti.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaComputer,
    [string]$PercorsoCSV = "C:\Report\StatoDefender.csv"
)

$computer = Get-Content -Path $ListaComputer

$risultati = foreach ($pc in $computer) {
    try {
        $stato = Invoke-Command -ComputerName $pc -ScriptBlock {
            Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled, AntivirusSignatureLastUpdated, AntivirusEnabled
        } -ErrorAction Stop

        [PSCustomObject]@{
            Computer               = $pc
            ProtezioneRealTime     = $stato.RealTimeProtectionEnabled
            AntivirusAttivo        = $stato.AntivirusEnabled
            UltimoAggiornamento    = $stato.AntivirusSignatureLastUpdated
            Stato                  = "OK"
        }
    }
    catch {
        [PSCustomObject]@{
            Computer            = $pc
            ProtezioneRealTime  = "N/D"
            AntivirusAttivo     = "N/D"
            UltimoAggiornamento = "N/D"
            Stato               = "NON RAGGIUNGIBILE: $_"
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$problemi = ($risultati | Where-Object {$_.ProtezioneRealTime -ne $true}).Count
Write-Host "Controllati $($computer.Count) computer. Con protezione non attiva: $problemi" -ForegroundColor $(if($problemi -gt 0){"Red"}else{"Green"})
