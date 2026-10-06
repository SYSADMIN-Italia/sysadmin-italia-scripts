<#
.SYNOPSIS
    Verifica che una lista di nomi DNS critici per l'infrastruttura si risolva correttamente.
#>
param(
    [Parameter(Mandatory=$true)]
    [string[]]$Nomi,
    [string]$PercorsoCSV = "C:\Report\ServiziDNSCritici.csv"
)

$risultati = foreach ($nome in $Nomi) {
    try {
        $risoluzione = Resolve-DnsName -Name $nome -ErrorAction Stop
        [PSCustomObject]@{
            Nome    = $nome
            IP      = ($risoluzione | Where-Object {$_.Type -eq "A"} | Select-Object -First 1).IPAddress
            Stato   = "OK"
        }
    }
    catch {
        [PSCustomObject]@{ Nome = $nome; IP = "N/D"; Stato = "ERRORE DI RISOLUZIONE: $_" }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$errori = ($risultati | Where-Object {$_.Stato -ne "OK"}).Count
Write-Host "Verificati $($Nomi.Count) nomi. Con errore: $errori" -ForegroundColor $(if($errori -gt 0){"Red"}else{"Green"})
