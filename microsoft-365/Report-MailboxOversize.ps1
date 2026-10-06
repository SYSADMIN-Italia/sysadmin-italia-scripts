<#
.SYNOPSIS
    Individua le mailbox che superano una soglia di dimensione configurabile.
#>
param(
    [double]$SogliaGB = 40,
    [string]$PercorsoCSV = "C:\Report\MailboxOversize.csv"
)

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowBanner:$false

$mailbox = Get-Mailbox -ResultSize Unlimited

$risultati = foreach ($mb in $mailbox) {
    $stats = Get-MailboxStatistics -Identity $mb.UserPrincipalName
    $sizeGB = [math]::Round(($stats.TotalItemSize.Value.ToBytes() / 1GB), 2)

    if ($sizeGB -ge $SogliaGB) {
        [PSCustomObject]@{
            Utente     = $mb.UserPrincipalName
            DimensioneGB = $sizeGB
            NumeroElementi = $stats.ItemCount
        }
    }
}

$risultati | Sort-Object DimensioneGB -Descending | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) mailbox sopra $SogliaGB GB." -ForegroundColor Yellow
Disconnect-ExchangeOnline -Confirm:$false
