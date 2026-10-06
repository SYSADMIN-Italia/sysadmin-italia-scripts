<#
.SYNOPSIS
    Esegue ping periodici verso un elenco di host, registrando ogni transizione di stato.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaHost,
    [int]$IntervalloSecondi = 60,
    [string]$LogPath = "C:\Report\UptimeLog.csv"
)

$host_elenco = Get-Content -Path $ListaHost
$statoPrecedente = @{}
foreach ($h in $host_elenco) { $statoPrecedente[$h] = $null }

Write-Host "Monitoraggio avviato su $($host_elenco.Count) host (Ctrl+C per interrompere)..." -ForegroundColor Cyan

while ($true) {
    foreach ($h in $host_elenco) {
        $raggiungibile = Test-Connection -ComputerName $h -Count 1 -Quiet -ErrorAction SilentlyContinue

        if ($statoPrecedente[$h] -ne $raggiungibile) {
            $evento = [PSCustomObject]@{
                Orario = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
                Host   = $h
                Stato  = if ($raggiungibile) {"TORNATO ONLINE"} else {"DIVENTATO IRRAGGIUNGIBILE"}
            }
            $evento | Export-Csv -Path $LogPath -NoTypeInformation -Encoding UTF8 -Delimiter ";" -Append

            $colore = if ($raggiungibile) {"Green"} else {"Red"}
            Write-Host "$($evento.Orario) - $h - $($evento.Stato)" -ForegroundColor $colore

            $statoPrecedente[$h] = $raggiungibile
        }
    }
    Start-Sleep -Seconds $IntervalloSecondi
}
