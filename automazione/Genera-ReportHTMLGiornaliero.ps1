<#
.SYNOPSIS
    Combina più controlli (disco, servizi, uptime) in un unico report HTML colorato.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaServer,
    [string]$PercorsoHTML = "C:\Report\ReportGiornaliero.html"
)

$server = Get-Content -Path $ListaServer
$righe = ""

foreach ($srv in $server) {
    try {
        $os = Get-CimInstance -ComputerName $srv -ClassName Win32_OperatingSystem -ErrorAction Stop
        $disco = Get-CimInstance -ComputerName $srv -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        $percentualeLibera = [math]::Round(($disco.FreeSpace / $disco.Size) * 100, 1)
        $uptime = ((Get-Date) - $os.LastBootUpTime).Days

        $coloreDisco = if ($percentualeLibera -lt 15) {"#FDECEA"} else {"#EAFAF1"}

        $righe += "<tr><td>$srv</td><td>OK</td><td style='background:$coloreDisco'>$percentualeLibera%</td><td>$uptime giorni</td></tr>"
    }
    catch {
        $righe += "<tr><td>$srv</td><td style='background:#FDECEA'>NON RAGGIUNGIBILE</td><td>-</td><td>-</td></tr>"
    }
}

$html = @"
<html><head><meta charset='utf-8'><style>
body{font-family:Arial,sans-serif;} table{border-collapse:collapse;width:100%;}
th,td{border:1px solid #ccc;padding:8px;text-align:left;} th{background:#16233F;color:white;}
</style></head><body>
<h2>Report giornaliero infrastruttura - $(Get-Date -Format 'dd/MM/yyyy')</h2>
<table><tr><th>Server</th><th>Stato</th><th>Spazio libero C:</th><th>Uptime</th></tr>
$righe
</table></body></html>
"@

$html | Out-File -FilePath $PercorsoHTML -Encoding UTF8
Write-Host "Report HTML generato in: $PercorsoHTML" -ForegroundColor Green
