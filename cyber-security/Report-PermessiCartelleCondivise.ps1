<#
.SYNOPSIS
    Analizza le condivisioni SMB locali e segnala quelle con permessi troppo ampi.
#>
param(
    [string]$PercorsoCSV = "C:\Report\PermessiCondivise.csv"
)

$condivisioni = Get-SmbShare | Where-Object { $_.Name -notlike "*$" }

$risultati = foreach ($share in $condivisioni) {
    $permessi = Get-SmbShareAccess -Name $share.Name

    foreach ($p in $permessi) {
        if ($p.AccountName -in @("Everyone", "Authenticated Users") -and $p.AccessRight -in @("Full", "Change")) {
            [PSCustomObject]@{
                Condivisione = $share.Name
                Percorso     = $share.Path
                Account      = $p.AccountName
                Permesso     = $p.AccessRight
            }
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) condivisioni con permessi ampi su Everyone/Authenticated Users." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
