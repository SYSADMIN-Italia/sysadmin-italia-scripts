<#
.SYNOPSIS
    Elenca tutte le porte TCP in ascolto con il processo associato.
#>
param(
    [string]$PercorsoCSV = "C:\Report\PorteInAscolto.csv"
)

$connessioni = Get-NetTCPConnection -State Listen

$risultati = foreach ($c in $connessioni) {
    $processo = Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Porta      = $c.LocalPort
        Indirizzo  = $c.LocalAddress
        Processo   = if ($processo) { $processo.ProcessName } else { "N/D" }
        PID        = $c.OwningProcess
    }
}

$risultati | Sort-Object Porta -Unique | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) porte in ascolto su $env:COMPUTERNAME." -ForegroundColor Green
