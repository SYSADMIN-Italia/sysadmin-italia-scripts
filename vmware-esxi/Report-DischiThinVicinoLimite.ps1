<#
.SYNOPSIS
    Individua VM con dischi thin provisioned su datastore con poco spazio libero residuo.
#>
param(
    [int]$SogliaLiberoPercento = 15,
    [string]$PercorsoCSV = "C:\Report\DischiThinVicinoLimite.csv"
)

$dischi = Get-VM | Get-HardDisk | Where-Object { $_.StorageFormat -eq "Thin" }

$risultati = foreach ($d in $dischi) {
    $datastore = Get-Datastore -Id $d.ExtensionData.Backing.Datastore
    $percentualeLibero = ($datastore.FreeSpaceGB / $datastore.CapacityGB) * 100

    if ($percentualeLibero -le $SogliaLiberoPercento) {
        [PSCustomObject]@{
            VM               = $d.Parent.Name
            Disco            = $d.Name
            DimensioneDiscoGB = [math]::Round($d.CapacityGB, 1)
            Datastore        = $datastore.Name
            PercentualeLiberaDatastore = [math]::Round($percentualeLibero, 1)
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) dischi thin su datastore con meno del $SogliaLiberoPercento% libero." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
