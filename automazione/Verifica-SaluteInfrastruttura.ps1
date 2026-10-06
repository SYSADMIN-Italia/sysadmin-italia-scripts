<#
.SYNOPSIS
    Esegue una serie combinata di controlli rapidi e produce un esito complessivo per sistema.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaServer,
    [string[]]$ServiziCritici = @("Spooler","W32Time"),
    [int]$SogliaDiscoPercento = 15
)

$server = Get-Content -Path $ListaServer

foreach ($srv in $server) {
    $problemi = @()

    $raggiungibile = Test-Connection -ComputerName $srv -Count 1 -Quiet -ErrorAction SilentlyContinue
    if (-not $raggiungibile) {
        Write-Host "$srv : FALLITO (non raggiungibile)" -ForegroundColor Red
        continue
    }

    try {
        $disco = Get-CimInstance -ComputerName $srv -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        $percentualeLibera = ($disco.FreeSpace / $disco.Size) * 100
        if ($percentualeLibera -lt $SogliaDiscoPercento) { $problemi += "disco C: sotto soglia ($([math]::Round($percentualeLibera,1))%)" }

        foreach ($svc in $ServiziCritici) {
            $stato = Get-CimInstance -ComputerName $srv -ClassName Win32_Service -Filter "Name='$svc'" -ErrorAction SilentlyContinue
            if ($stato -and $stato.State -ne "Running") { $problemi += "servizio $svc non attivo" }
        }
    }
    catch {
        $problemi += "impossibile verificare disco/servizi: $_"
    }

    if ($problemi.Count -eq 0) {
        Write-Host "$srv : OK" -ForegroundColor Green
    } else {
        Write-Host "$srv : ATTENZIONE - $($problemi -join '; ')" -ForegroundColor Yellow
    }
}
