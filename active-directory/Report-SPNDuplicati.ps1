<#
.SYNOPSIS
    Individua Service Principal Name (SPN) duplicati nel dominio.
#>
param(
    [string]$PercorsoCSV = "C:\Report\SPNDuplicati.csv"
)

Import-Module ActiveDirectory

$tuttiGliOggetti = Get-ADObject -Filter {servicePrincipalName -like "*"} -Properties servicePrincipalName, DistinguishedName

$mappaSPN = @{}

foreach ($obj in $tuttiGliOggetti) {
    foreach ($spn in $obj.servicePrincipalName) {
        if ($mappaSPN.ContainsKey($spn)) {
            $mappaSPN[$spn] += $obj.DistinguishedName
        } else {
            $mappaSPN[$spn] = @($obj.DistinguishedName)
        }
    }
}

$duplicati = $mappaSPN.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }

$risultati = foreach ($d in $duplicati) {
    [PSCustomObject]@{
        SPN       = $d.Key
        Oggetti   = ($d.Value -join " | ")
        Conteggio = $d.Value.Count
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) SPN duplicati." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
