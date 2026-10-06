<#
.SYNOPSIS
    Verifica da quanto tempo ogni server è attivo dall'ultimo riavvio.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaServer,
    [string]$PercorsoCSV = "C:\Report\UptimeServer.csv"
)

$server = Get-Content -Path $ListaServer

$risultati = foreach ($srv in $server) {
    try {
        $os = Get-CimInstance -ComputerName $srv -ClassName Win32_OperatingSystem -ErrorAction Stop
        $uptime = (Get-Date) - $os.LastBootUpTime

        [PSCustomObject]@{
            Server        = $srv
            UltimoAvvio   = $os.LastBootUpTime.ToString("dd/MM/yyyy HH:mm")
            GiorniUptime  = $uptime.Days
        }
    }
    catch {
        [PSCustomObject]@{ Server = $srv; UltimoAvvio = "N/D"; GiorniUptime = "NON RAGGIUNGIBILE" }
    }
}

$risultati | Sort-Object GiorniUptime -Descending | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Controllati $($server.Count) server." -ForegroundColor Green
