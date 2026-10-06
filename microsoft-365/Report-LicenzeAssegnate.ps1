<#
.SYNOPSIS
    Riepiloga per ogni SKU di licenza quante ne sono totali, assegnate e disponibili.
#>
param(
    [string]$PercorsoCSV = "C:\Report\LicenzeAssegnate.csv"
)

Import-Module Microsoft.Graph.Users
Connect-MgGraph -Scopes "Organization.Read.All" -NoWelcome

$skus = Get-MgSubscribedSku

$risultati = foreach ($sku in $skus) {
    [PSCustomObject]@{
        SKU         = $sku.SkuPartNumber
        Totali      = $sku.PrepaidUnits.Enabled
        Assegnate   = $sku.ConsumedUnits
        Disponibili = $sku.PrepaidUnits.Enabled - $sku.ConsumedUnits
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportate $($risultati.Count) SKU di licenza in: $PercorsoCSV" -ForegroundColor Green
