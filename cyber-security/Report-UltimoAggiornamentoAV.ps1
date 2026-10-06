<#
.SYNOPSIS
    Verifica quando ogni endpoint ha aggiornato per l'ultima volta le firme antivirus.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaComputer,
    [int]$GiorniSoglia = 3,
    [string]$PercorsoCSV = "C:\Report\AggiornamentoAV.csv"
)

$computer = Get-Content -Path $ListaComputer

$risultati = foreach ($pc in $computer) {
    try {
        $stato = Invoke-Command -ComputerName $pc -ScriptBlock {
            Get-MpComputerStatus | Select-Object AntivirusSignatureLastUpdated
        } -ErrorAction Stop

        $giorni = ((Get-Date) - $stato.AntivirusSignatureLastUpdated).Days

        [PSCustomObject]@{
            Computer            = $pc
            UltimoAggiornamento = $stato.AntivirusSignatureLastUpdated
            GiorniFa            = $giorni
            Stato               = if ($giorni -gt $GiorniSoglia) {"DA AGGIORNARE"} else {"OK"}
        }
    }
    catch {
        [PSCustomObject]@{ Computer = $pc; UltimoAggiornamento = "N/D"; GiorniFa = "N/D"; Stato = "NON RAGGIUNGIBILE: $_" }
    }
}

$risultati | Sort-Object GiorniFa -Descending | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$daAggiornare = ($risultati | Where-Object {$_.Stato -eq "DA AGGIORNARE"}).Count
Write-Host "Controllati $($computer.Count) computer. Da aggiornare: $daAggiornare" -ForegroundColor $(if($daAggiornare -gt 0){"Red"}else{"Green"})
