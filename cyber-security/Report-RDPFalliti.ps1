<#
.SYNOPSIS
    Analizza il log eventi per tentativi di accesso RDP falliti (logon type 10).
#>
param(
    [int]$OreIndietro = 24,
    [string]$PercorsoCSV = "C:\Report\RDPFalliti.csv"
)

$dataLimite = (Get-Date).AddHours(-$OreIndietro)

$eventi = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=$dataLimite} -ErrorAction SilentlyContinue

$risultati = foreach ($e in $eventi) {
    $xml = [xml]$e.ToXml()
    $dati = $xml.Event.EventData.Data
    $logonType = ($dati | Where-Object {$_.Name -eq 'LogonType'}).'#text'

    if ($logonType -eq '10') {
        [PSCustomObject]@{
            Orario    = $e.TimeCreated
            Account   = ($dati | Where-Object {$_.Name -eq 'TargetUserName'}).'#text'
            IPOrigine = ($dati | Where-Object {$_.Name -eq 'IpAddress'}).'#text'
        }
    }
}

$riepilogo = $risultati | Group-Object IPOrigine | Sort-Object Count -Descending |
    Select-Object @{N="IPOrigine";E={$_.Name}}, Count

$riepilogo | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) tentativi RDP falliti da $($riepilogo.Count) IP diversi nelle ultime $OreIndietro ore." -ForegroundColor $(if($risultati.Count -gt 0){"Yellow"}else{"Green"})
