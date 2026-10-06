<#
.SYNOPSIS
    Estrae dal registro di controllo unificato le operazioni amministrative più recenti.
#>
param(
    [int]$OreIndietro = 24,
    [string]$PercorsoCSV = "C:\Report\AuditAmministrativo.csv"
)

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowBanner:$false

$dataInizio = (Get-Date).AddHours(-$OreIndietro)
$dataFine = Get-Date

$operazioni = @("Add-MailboxPermission","Add member to group","Add member to role",
    "Set-Mailbox","Update user","Add user")

$risultati = Search-UnifiedAuditLog -StartDate $dataInizio -EndDate $dataFine -Operations $operazioni -ResultSize 500 |
    Select-Object CreationDate, UserIds, Operations, ResultIndex

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) operazioni amministrative nelle ultime $OreIndietro ore." -ForegroundColor Cyan
Disconnect-ExchangeOnline -Confirm:$false
