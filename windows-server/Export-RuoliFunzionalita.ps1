<#
.SYNOPSIS
    Esporta l'elenco completo dei ruoli e delle funzionalità di Windows Server installati.
#>
param(
    [string]$PercorsoCSV = "C:\Report\RuoliFunzionalita.csv"
)

Import-Module ServerManager

$componenti = Get-WindowsFeature | Where-Object { $_.InstallState -eq "Installed" }

$risultati = $componenti | Select-Object Name, DisplayName, FeatureType

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportati $($risultati.Count) ruoli/funzionalita installati su $env:COMPUTERNAME." -ForegroundColor Green
