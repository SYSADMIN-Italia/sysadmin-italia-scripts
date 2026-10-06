<#
.SYNOPSIS
    Elenca le Group Policy modificate negli ultimi N giorni.
#>
param(
    [int]$GiorniIndietro = 7,
    [string]$PercorsoCSV = "C:\Report\ModificheGPO.csv"
)

Import-Module GroupPolicy

$dataLimite = (Get-Date).AddDays(-$GiorniIndietro)

$gpo = Get-GPO -All | Where-Object { $_.ModificationTime -gt $dataLimite }

$risultati = $gpo | Select-Object DisplayName,
    @{N="UltimaModifica";E={$_.ModificationTime.ToString("dd/MM/yyyy HH:mm")}},
    @{N="Creata";E={$_.CreationTime.ToString("dd/MM/yyyy")}},
    Owner, GpoStatus

$risultati | Sort-Object UltimaModifica -Descending | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) GPO modificate negli ultimi $GiorniIndietro giorni." -ForegroundColor Yellow
