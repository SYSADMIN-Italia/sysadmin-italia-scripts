<#
.SYNOPSIS
    Elenca tutte le stampanti condivise su un server con lo stato corrente di ciascuna.
#>
param(
    [string]$PercorsoCSV = "C:\Report\StampantiCondivise.csv"
)

$stampanti = Get-Printer | Where-Object { $_.Shared -eq $true }

$risultati = foreach ($p in $stampanti) {
    $lavori = Get-PrintJob -PrinterName $p.Name -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Stampante   = $p.Name
        NomeCondiviso = $p.ShareName
        Stato       = $p.PrinterStatus
        LavoriInCoda = $lavori.Count
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$problemi = ($risultati | Where-Object {$_.Stato -ne "Normal"}).Count
Write-Host "Controllate $($stampanti.Count) stampanti condivise. Con problemi: $problemi" -ForegroundColor $(if($problemi -gt 0){"Red"}else{"Green"})
