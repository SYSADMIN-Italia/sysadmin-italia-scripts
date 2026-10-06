<#
.SYNOPSIS
    Individua le macchine virtuali con snapshot più vecchi della soglia configurata.
#>
param(
    [int]$GiorniSoglia = 3,
    [string]$PercorsoCSV = "C:\Report\SnapshotVecchi.csv"
)

$snapshot = Get-VM | Get-Snapshot

$dataLimite = (Get-Date).AddDays(-$GiorniSoglia)

$risultati = $snapshot | Where-Object { $_.Created -lt $dataLimite } | Select-Object
    @{N="VM";E={$_.VM.Name}}, Name, Created,
    @{N="GiorniEta";E={((Get-Date) - $_.Created).Days}},
    @{N="DimensioneGB";E={[math]::Round($_.SizeGB, 2)}}

$risultati | Sort-Object GiorniEta -Descending | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) snapshot piu vecchi di $GiorniSoglia giorni." -ForegroundColor $(if($risultati.Count -gt 0){"Yellow"}else{"Green"})
