<#
.SYNOPSIS
    Verifica lo stato di cifratura BitLocker su un elenco di computer.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaComputer,
    [string]$PercorsoCSV = "C:\Report\StatoBitLocker.csv"
)

$computer = Get-Content -Path $ListaComputer

$risultati = foreach ($pc in $computer) {
    try {
        $volumi = Invoke-Command -ComputerName $pc -ScriptBlock {
            Get-BitLockerVolume | Select-Object MountPoint, ProtectionStatus, VolumeStatus
        } -ErrorAction Stop

        foreach ($v in $volumi) {
            [PSCustomObject]@{
                Computer   = $pc
                Volume     = $v.MountPoint
                Protezione = $v.ProtectionStatus
                Stato      = $v.VolumeStatus
            }
        }
    }
    catch {
        [PSCustomObject]@{ Computer = $pc; Volume = "N/D"; Protezione = "N/D"; Stato = "NON RAGGIUNGIBILE: $_" }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$nonProtetti = ($risultati | Where-Object {$_.Protezione -eq "Off"}).Count
Write-Host "Controllati $($computer.Count) computer. Volumi non protetti: $nonProtetti" -ForegroundColor $(if($nonProtetti -gt 0){"Red"}else{"Green"})
