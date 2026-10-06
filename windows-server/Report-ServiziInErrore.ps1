<#
.SYNOPSIS
    Individua i servizi configurati per l'avvio automatico ma che risultano fermi.
#>
param(
    [string]$PercorsoCSV = "C:\Report\ServiziInErrore.csv"
)

$servizi = Get-CimInstance -ClassName Win32_Service -Filter "StartMode='Auto' AND State='Stopped'"

$risultati = $servizi | Select-Object Name, DisplayName, State, StartMode, @{N="Account";E={$_.StartName}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) servizi automatici fermi su $env:COMPUTERNAME." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
