<#
.SYNOPSIS
    Esporta tutte le caselle di posta condivise e chi ha accesso a ciascuna.
#>
param(
    [string]$PercorsoCSV = "C:\Report\CaselleCondivise.csv"
)

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowBanner:$false

$condivise = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited

$risultati = foreach ($mb in $condivise) {
    $permessi = Get-MailboxPermission -Identity $mb.UserPrincipalName |
        Where-Object { $_.User -notlike "NT AUTHORITY\*" -and $_.IsInherited -eq $false }

    foreach ($p in $permessi) {
        [PSCustomObject]@{
            CasellaCondivisa = $mb.UserPrincipalName
            Utente           = $p.User
            Permesso         = ($p.AccessRights -join ", ")
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportate $($condivise.Count) caselle condivise con relativi permessi." -ForegroundColor Green
Disconnect-ExchangeOnline -Confirm:$false
