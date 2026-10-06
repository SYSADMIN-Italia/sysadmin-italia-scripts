<#
.SYNOPSIS
    Interroga più computer e riporta i membri del gruppo Administrators locale su ciascuno.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaComputer,
    [string]$PercorsoCSV = "C:\Report\AdminLocali.csv"
)

$computer = Get-Content -Path $ListaComputer

$risultati = foreach ($pc in $computer) {
    try {
        $membri = Invoke-Command -ComputerName $pc -ScriptBlock {
            Get-LocalGroupMember -Group "Administrators" | Select-Object Name, ObjectClass
        } -ErrorAction Stop

        foreach ($m in $membri) {
            [PSCustomObject]@{
                Computer = $pc
                Membro   = $m.Name
                Tipo     = $m.ObjectClass
                Stato    = "OK"
            }
        }
    }
    catch {
        [PSCustomObject]@{
            Computer = $pc
            Membro   = "N/D"
            Tipo     = "N/D"
            Stato    = "NON RAGGIUNGIBILE: $_"
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Report generato per $($computer.Count) computer in: $PercorsoCSV" -ForegroundColor Green
