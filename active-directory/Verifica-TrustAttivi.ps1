<#
.SYNOPSIS
    Elenca tutti i trust configurati per il dominio corrente e ne verifica lo stato di salute.
#>
param(
    [string]$PercorsoCSV = "C:\Report\TrustDominio.csv"
)

Import-Module ActiveDirectory

$trust = Get-ADTrust -Filter *

if (-not $trust) {
    Write-Host "Nessun trust configurato per questo dominio." -ForegroundColor Cyan
    return
}

$risultati = foreach ($t in $trust) {
    $statoOk = $true
    try {
        $test = Test-ComputerSecureChannel -Server $t.Target -ErrorAction Stop
    }
    catch {
        $statoOk = $false
    }

    [PSCustomObject]@{
        DominioTarget = $t.Target
        Direzione     = $t.Direction
        Tipo          = $t.TrustType
        Transitivo    = $t.ForestTransitive
        StatoVerifica = if ($statoOk) {"OK"} else {"DA VERIFICARE MANUALMENTE"}
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportati $($risultati.Count) trust in: $PercorsoCSV" -ForegroundColor Green
