<#
.SYNOPSIS
    Cerca file modificati in un intervallo di tempo sospetto, indicatore possibile di ransomware attivo.
#>
param(
    [Parameter(Mandatory=$true)]
    [string[]]$Percorsi,
    [int]$MinutiIndietro = 15,
    [int]$SogliaFileSospetta = 50,
    [string]$PercorsoCSV = "C:\Report\FileModificatiRecenti.csv"
)

$dataLimite = (Get-Date).AddMinutes(-$MinutiIndietro)

$fileModificati = foreach ($percorso in $Percorsi) {
    Get-ChildItem -Path $percorso -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt $dataLimite }
}

$perCartella = $fileModificati | Group-Object DirectoryName | Sort-Object Count -Descending

$riepilogo = $perCartella | Select-Object @{N="Cartella";E={$_.Name}}, Count

$riepilogo | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"

$cartelleSospette = $perCartella | Where-Object { $_.Count -ge $SogliaFileSospetta }
if ($cartelleSospette) {
    Write-Host "[ALLARME] $($cartelleSospette.Count) cartelle con oltre $SogliaFileSospetta modifiche negli ultimi $MinutiIndietro minuti!" -ForegroundColor Red
} else {
    Write-Host "Nessuna cartella supera la soglia di $SogliaFileSospetta modifiche in $MinutiIndietro minuti." -ForegroundColor Green
}
