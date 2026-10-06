<#
.SYNOPSIS
    Verifica lo stato di DKIM su Exchange Online e la presenza dei record SPF/DMARC nel DNS.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Dominio
)

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "=== DKIM ===" -ForegroundColor Cyan
$dkim = Get-DkimSigningConfig -Identity $Dominio -ErrorAction SilentlyContinue
if ($dkim) {
    Write-Host "DKIM abilitato: $($dkim.Enabled)" -ForegroundColor $(if($dkim.Enabled){"Green"}else{"Red"})
} else {
    Write-Host "Nessuna configurazione DKIM trovata per $Dominio." -ForegroundColor Red
}

Write-Host "`n=== SPF ===" -ForegroundColor Cyan
$spf = Resolve-DnsName -Name $Dominio -Type TXT -ErrorAction SilentlyContinue | Where-Object { $_.Strings -match "v=spf1" }
if ($spf) { Write-Host "Record SPF trovato: $($spf.Strings)" -ForegroundColor Green }
else { Write-Host "Nessun record SPF trovato." -ForegroundColor Red }

Write-Host "`n=== DMARC ===" -ForegroundColor Cyan
$dmarc = Resolve-DnsName -Name "_dmarc.$Dominio" -Type TXT -ErrorAction SilentlyContinue
if ($dmarc) { Write-Host "Record DMARC trovato: $($dmarc.Strings)" -ForegroundColor Green }
else { Write-Host "Nessun record DMARC trovato." -ForegroundColor Red }

Disconnect-ExchangeOnline -Confirm:$false
