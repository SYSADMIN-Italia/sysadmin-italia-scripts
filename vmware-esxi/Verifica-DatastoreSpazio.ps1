<#
.SYNOPSIS
    Verifica lo spazio libero su tutti i datastore, segnalando quelli sotto la soglia configurata.
#>
param(
    [int]$SogliaAllarmePercento = 85,
    [string]$PercorsoCSV = "C:\Report\StatoDatastore.csv"
)

$datastore = Get-Datastore

$risultati = $datastore | Select-Object Name,
    @{N="CapacitaGB";E={[math]::Round($_.CapacityGB, 1)}},
    @{N="LiberoGB";E={[math]::Round($_.FreeSpaceGB, 1)}},
    @{N="PercentualeUso";E={[math]::Round((1 - ($_.FreeSpaceGB / $_.CapacityGB)) * 100, 1)}},
    @{N="Allarme";E={if ((1 - ($_.FreeSpaceGB / $_.CapacityGB)) * 100 -ge $SogliaAllarmePercento) {"SI"} else {"NO"}}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$inAllarme = ($risultati | Where-Object {$_.Allarme -eq "SI"}).Count
Write-Host "Controllati $($datastore.Count) datastore. In allarme: $inAllarme" -ForegroundColor $(if($inAllarme -gt 0){"Red"}else{"Green"})
