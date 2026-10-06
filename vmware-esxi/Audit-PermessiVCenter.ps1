<#
.SYNOPSIS
    Esporta tutti i permessi assegnati a utenti e gruppi su vCenter.
#>
param(
    [string]$PercorsoCSV = "C:\Report\PermessiVCenter.csv"
)

$permessi = Get-VIPermission

$risultati = $permessi | Select-Object
    @{N="Entita";E={$_.Principal}},
    @{N="Ruolo";E={$_.Role}},
    @{N="Ambito";E={$_.Entity.Name}},
    @{N="Propagato";E={$_.Propagate}},
    @{N="Gruppo";E={$_.IsGroup}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportati $($risultati.Count) permessi in: $PercorsoCSV" -ForegroundColor Green
