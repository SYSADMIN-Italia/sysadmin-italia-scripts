<#
.SYNOPSIS
    Interroga il servizio Windows Update locale e riporta gli aggiornamenti mancanti.
#>
param(
    [string]$PercorsoCSV = "C:\Report\AggiornamentiMancanti.csv"
)

$updateSession = New-Object -ComObject Microsoft.Update.Session
$updateSearcher = $updateSession.CreateUpdateSearcher()

Write-Host "Ricerca aggiornamenti in corso, potrebbe richiedere qualche minuto..." -ForegroundColor Cyan
$risultatoRicerca = $updateSearcher.Search("IsInstalled=0 and IsHidden=0")

$risultati = foreach ($update in $risultatoRicerca.Updates) {
    [PSCustomObject]@{
        Titolo    = $update.Title
        Categoria = ($update.Categories | Select-Object -First 1).Name
        KB        = ($update.KBArticleIDs -join ", ")
        Critico   = $update.MsrcSeverity
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) aggiornamenti mancanti su $env:COMPUTERNAME." -ForegroundColor $(if($risultati.Count -gt 0){"Yellow"}else{"Green"})
