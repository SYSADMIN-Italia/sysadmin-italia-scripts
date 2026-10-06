<#
.SYNOPSIS
    Elenca tutte le connessioni attive su un server MySQL.
.NOTES
    Richiede il client a riga di comando "mysql" installato e raggiungibile nel PATH.
#>
param(
    [string]$ServerMySQL = "localhost",
    [string]$Utente = "root",
    [string]$Password,
    [string]$PercorsoCSV = "C:\Report\ConnessioniMySQL.csv"
)

$query = "SHOW FULL PROCESSLIST;"
$risultatoGrezzo = & mysql -h $ServerMySQL -u $Utente -p"$Password" -e $query --batch --raw 2>$null

$righe = $risultatoGrezzo | Select-Object -Skip 1
$risultati = foreach ($riga in $righe) {
    $campi = $riga -split "`t"
    [PSCustomObject]@{
        Id = $campi[0]; Utente = $campi[1]; Host = $campi[2]; Database = $campi[3]
        Comando = $campi[4]; Tempo = $campi[5]; Stato = $campi[6]
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) connessioni attive su MySQL $ServerMySQL." -ForegroundColor Green
