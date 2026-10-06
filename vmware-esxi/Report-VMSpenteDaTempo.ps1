<#
.SYNOPSIS
    Individua le macchine virtuali spente da più della soglia di giorni configurata.
#>
param(
    [int]$GiorniSoglia = 30,
    [string]$PercorsoCSV = "C:\Report\VMSpenteDaTempo.csv"
)

$vm = Get-VM | Where-Object { $_.PowerState -eq "PoweredOff" }

$risultati = foreach ($v in $vm) {
    $ultimoEvento = Get-VIEvent -Entity $v -Types Info -Start (Get-Date).AddYears(-2) |
        Where-Object { $_.GetType().Name -like "*PoweredOff*" } |
        Sort-Object CreatedTime -Descending | Select-Object -First 1

    $giorniSpenta = if ($ultimoEvento) { ((Get-Date) - $ultimoEvento.CreatedTime).Days } else { "Sconosciuto" }

    if ($giorniSpenta -eq "Sconosciuto" -or $giorniSpenta -ge $GiorniSoglia) {
        [PSCustomObject]@{
            VM              = $v.Name
            GiorniSpenta    = $giorniSpenta
            StorageGB       = [math]::Round($v.ProvisionedSpaceGB, 1)
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) VM spente da oltre $GiorniSoglia giorni (o data sconosciuta)." -ForegroundColor Yellow
