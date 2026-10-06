<#
.SYNOPSIS
    Individua regole di inoltro automatico verso indirizzi esterni al dominio aziendale.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$DominioAziendale,
    [string]$PercorsoCSV = "C:\Report\InoltriSospetti.csv"
)

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowBanner:$false

$mailbox = Get-Mailbox -ResultSize Unlimited

$risultati = @()

foreach ($mb in $mailbox) {
    if ($mb.ForwardingSmtpAddress -and $mb.ForwardingSmtpAddress -notlike "*@$DominioAziendale*") {
        $risultati += [PSCustomObject]@{
            Utente = $mb.UserPrincipalName
            Tipo   = "Inoltro mailbox"
            Destinazione = $mb.ForwardingSmtpAddress
        }
    }

    $regole = Get-InboxRule -Mailbox $mb.UserPrincipalName -ErrorAction SilentlyContinue |
        Where-Object { $_.ForwardTo -or $_.RedirectTo }

    foreach ($r in $regole) {
        $destinazioni = @($r.ForwardTo) + @($r.RedirectTo) | Where-Object { $_ -and $_ -notlike "*$DominioAziendale*" }
        foreach ($d in $destinazioni) {
            $risultati += [PSCustomObject]@{
                Utente = $mb.UserPrincipalName
                Tipo   = "Regola: $($r.Name)"
                Destinazione = $d
            }
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) regole di inoltro verso l'esterno." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
Disconnect-ExchangeOnline -Confirm:$false
