<#
.SYNOPSIS
    Mostra a console un riepilogo compatto dello stato di più sistemi.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaServer
)

$server = Get-Content -Path $ListaServer

Write-Host ("{0,-20} {1,-12} {2,-15} {3,-12}" -f "SERVER", "STATO", "DISCO C:", "UPTIME") -ForegroundColor Cyan
Write-Host ("-" * 62)

foreach ($srv in $server) {
    try {
        $os = Get-CimInstance -ComputerName $srv -ClassName Win32_OperatingSystem -ErrorAction Stop
        $disco = Get-CimInstance -ComputerName $srv -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop

        $percentualeLibera = [math]::Round(($disco.FreeSpace / $disco.Size) * 100, 0)
        $uptime = ((Get-Date) - $os.LastBootUpTime).Days
        $coloreDisco = if ($percentualeLibera -lt 15) {"Red"} else {"White"}

        Write-Host ("{0,-20} {1,-12} " -f $srv, "ONLINE") -NoNewline -ForegroundColor Green
        Write-Host ("{0,-15} " -f "$percentualeLibera% liberi") -NoNewline -ForegroundColor $coloreDisco
        Write-Host ("{0,-12}" -f "$uptime giorni")
    }
    catch {
        Write-Host ("{0,-20} {1,-12} {2,-15} {3,-12}" -f $srv, "OFFLINE", "-", "-") -ForegroundColor Red
    }
}
