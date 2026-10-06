<#
.SYNOPSIS
    Elenca le policy di conservazione (retention) configurate nel centro conformità.
#>
param(
    [string]$PercorsoCSV = "C:\Report\PolicyConservazione.csv"
)

Import-Module ExchangeOnlineManagement
Connect-IPPSSession

$policy = Get-RetentionCompliancePolicy

$risultati = foreach ($p in $policy) {
    $regole = Get-RetentionComplianceRule -Policy $p.Name -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Policy    = $p.Name
        Abilitata = $p.Enabled
        Ambito    = ($p.ExchangeLocation -join ", ")
        NumeroRegole = $regole.Count
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportate $($risultati.Count) policy di conservazione." -ForegroundColor Green
