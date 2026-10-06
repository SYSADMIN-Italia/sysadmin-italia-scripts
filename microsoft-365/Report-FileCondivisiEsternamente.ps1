<#
.SYNOPSIS
    Recupera i siti SharePoint/OneDrive con condivisione esterna attiva.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$TenantAdminUrl,
    [string]$PercorsoCSV = "C:\Report\CondivisioneEsterna.csv"
)

Import-Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url $TenantAdminUrl

$siti = Get-SPOSite -Limit All -IncludePersonalSite $true

$risultati = $siti | Where-Object { $_.SharingCapability -ne "Disabled" } |
    Select-Object Url, Owner, SharingCapability, StorageUsageCurrent

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) siti con condivisione esterna abilitata." -ForegroundColor Yellow
