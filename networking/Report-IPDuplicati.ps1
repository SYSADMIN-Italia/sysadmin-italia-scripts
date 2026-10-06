<#
.SYNOPSIS
    Esegue un ping sweep e analizza la cache ARP per individuare possibili conflitti IP.
.NOTES
    La cache ARP è volatile: questo script è un indizio diagnostico, non una prova definitiva.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$IPIniziale,
    [Parameter(Mandatory=$true)]
    [string]$IPFinale
)

function ConvertTo-UInt32 ([string]$ip) {
    $b = $ip.Split('.')
    return ([uint32]$b[0] -shl 24) + ([uint32]$b[1] -shl 16) + ([uint32]$b[2] -shl 8) + [uint32]$b[3]
}
function ConvertTo-IPString ([uint32]$num) {
    return "{0}.{1}.{2}.{3}" -f (($num -shr 24) -band 255), (($num -shr 16) -band 255), (($num -shr 8) -band 255), ($num -band 255)
}

$start = ConvertTo-UInt32 $IPIniziale
$end = ConvertTo-UInt32 $IPFinale

for ($i = $start; $i -le $end; $i++) {
    Test-Connection -ComputerName (ConvertTo-IPString $i) -Count 1 -Quiet -ErrorAction SilentlyContinue | Out-Null
}

$arp = Get-NetNeighbor -AddressFamily IPv4 | Where-Object { $_.State -ne "Unreachable" -and $_.LinkLayerAddress -ne "00-00-00-00-00-00" }

$sospetti = $arp | Group-Object LinkLayerAddress | Where-Object { $_.Count -gt 1 }

if ($sospetti) {
    Write-Host "[ATTENZIONE] Possibili conflitti IP rilevati:" -ForegroundColor Red
    foreach ($s in $sospetti) {
        Write-Host "  MAC $($s.Name) associato a: $($s.Group.IPAddress -join ', ')" -ForegroundColor Red
    }
} else {
    Write-Host "Nessun conflitto IP evidente rilevato nella cache ARP corrente." -ForegroundColor Green
}
