<#
.SYNOPSIS
    Elenca i client con lease DHCP che scadranno entro una finestra di tempo configurabile.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ScopeId,
    [int]$OreFinestra = 4,
    [string]$PercorsoCSV = "C:\Report\LeaseDHCPScadenza.csv"
)

Import-Module DhcpServer

$dataLimite = (Get-Date).AddHours($OreFinestra)

$lease = Get-DhcpServerv4Lease -ScopeId $ScopeId | Where-Object { $_.LeaseExpiryTime -lt $dataLimite }

$risultati = $lease | Select-Object IPAddress, ClientId, HostName,
    @{N="Scadenza";E={$_.LeaseExpiryTime.ToString("dd/MM/yyyy HH:mm")}}

$risultati | Sort-Object Scadenza | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) lease in scadenza entro $OreFinestra ore." -ForegroundColor Yellow
