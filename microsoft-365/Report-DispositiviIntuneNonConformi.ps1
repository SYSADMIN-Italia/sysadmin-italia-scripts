<#
.SYNOPSIS
    Elenca i dispositivi Intune che risultano non conformi alle policy configurate.
#>
param(
    [string]$PercorsoCSV = "C:\Report\DispositiviNonConformi.csv"
)

Import-Module Microsoft.Graph.DeviceManagement
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All" -NoWelcome

$dispositivi = Get-MgDeviceManagementManagedDevice -Filter "complianceState eq 'noncompliant'" -All

$risultati = $dispositivi | Select-Object DeviceName, UserPrincipalName, OperatingSystem,
    ComplianceState, LastSyncDateTime

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) dispositivi non conformi." -ForegroundColor $(if($risultati.Count -gt 0){"Yellow"}else{"Green"})
