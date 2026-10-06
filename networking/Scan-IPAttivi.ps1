<#
.SYNOPSIS
    Esegue un ping sweep su una subnet, riportando gli indirizzi IP che rispondono.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$IPIniziale,
    [Parameter(Mandatory=$true)]
    [string]$IPFinale,
    [string]$PercorsoCSV = "C:\Report\IPAttivi.csv"
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

$risultati = for ($i = $start; $i -le $end; $i++) {
    $ip = ConvertTo-IPString $i
    $test = Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue

    if ($test) {
        $nome = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { "N/D" }
        [PSCustomObject]@{ IP = $ip; NomeHost = $nome; Stato = "ATTIVO" }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) IP attivi nel range specificato." -ForegroundColor Green
