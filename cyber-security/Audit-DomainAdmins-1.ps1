<#
.SYNOPSIS
    Elenca i membri attuali di Domain Admins, confrontandoli con un elenco di riferimento atteso.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ElencoAtteso
)

Import-Module ActiveDirectory

$membriAttuali = (Get-ADGroupMember -Identity "Domain Admins" -Recursive).SamAccountName
$membriAttesi = Get-Content -Path $ElencoAtteso

$nonPrevisti = $membriAttuali | Where-Object { $_ -notin $membriAttesi }
$mancanti = $membriAttesi | Where-Object { $_ -notin $membriAttuali }

Write-Host "=== Membri attuali di Domain Admins: $($membriAttuali.Count) ===" -ForegroundColor Cyan
$membriAttuali | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

if ($nonPrevisti) {
    Write-Host "`n[ATTENZIONE] Membri NON previsti nell'elenco di riferimento:" -ForegroundColor Red
    $nonPrevisti | ForEach-Object { Write-Host "  ! $_" -ForegroundColor Red }
}
if ($mancanti) {
    Write-Host "`n[INFO] Membri attesi ma non piu presenti:" -ForegroundColor Yellow
    $mancanti | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
if (-not $nonPrevisti -and -not $mancanti) {
    Write-Host "`nNessuna discrepanza rilevata." -ForegroundColor Green
}
