<#
.SYNOPSIS
    Raccoglie eventi specifici da più server in un unico file di log centralizzato.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaServer,
    [string]$NomeLog = "Application",
    [int]$OreIndietro = 1,
    [string]$LogCentralizzato = "C:\Report\LogCentralizzato.csv"
)

$server = Get-Content -Path $ListaServer
$dataLimite = (Get-Date).AddHours(-$OreIndietro)

$eventi = foreach ($srv in $server) {
    try {
        Get-WinEvent -ComputerName $srv -FilterHashtable @{LogName=$NomeLog; Level=(1,2); StartTime=$dataLimite} -ErrorAction Stop |
            Select-Object @{N="Server";E={$srv}}, TimeCreated, Id, LevelDisplayName,
                @{N="Messaggio";E={$_.Message.Split("`n")[0]}}
    }
    catch {
        Write-Host "Impossibile leggere il log da $srv : $_" -ForegroundColor Yellow
    }
}

$eventi | Export-Csv -Path $LogCentralizzato -NoTypeInformation -Encoding UTF8 -Delimiter ";" -Append
Write-Host "Raccolti $($eventi.Count) eventi da $($server.Count) server in: $LogCentralizzato" -ForegroundColor Green
