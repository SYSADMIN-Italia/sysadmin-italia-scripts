<#
.SYNOPSIS
    Esporta lo spazio utilizzato su OneDrive da ciascun utente tramite i report Microsoft Graph.
#>
param(
    [string]$PercorsoCSV = "C:\Report\UtilizzoOneDrive.csv"
)

Import-Module Microsoft.Graph.Reports
Connect-MgGraph -Scopes "Reports.Read.All" -NoWelcome

$reportPath = "C:\Report\_temp_onedrive_usage.csv"
Get-MgReportOneDriveUsageAccountDetail -Period D30 -OutFile $reportPath

$dati = Import-Csv -Path $reportPath

$risultati = $dati | Select-Object "Owner Principal Name",
    @{N="SpazioUsatoGB";E={[math]::Round([double]$_."Storage Used (Byte)" / 1GB, 2)}},
    @{N="SpazioAllocatoGB";E={[math]::Round([double]$_."Storage Allocated (Byte)" / 1GB, 2)}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportato l'utilizzo OneDrive per $($risultati.Count) utenti." -ForegroundColor Green
Remove-Item $reportPath -ErrorAction SilentlyContinue
