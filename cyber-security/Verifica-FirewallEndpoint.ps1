<#
.SYNOPSIS
    Verifica che il firewall Windows sia attivo su tutti i profili di rete su un elenco di computer.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaComputer,
    [string]$PercorsoCSV = "C:\Report\StatoFirewall.csv"
)

$computer = Get-Content -Path $ListaComputer

$risultati = foreach ($pc in $computer) {
    try {
        $profili = Invoke-Command -ComputerName $pc -ScriptBlock {
            Get-NetFirewallProfile | Select-Object Name, Enabled
        } -ErrorAction Stop

        foreach ($p in $profili) {
            [PSCustomObject]@{
                Computer = $pc
                Profilo  = $p.Name
                Attivo   = $p.Enabled
            }
        }
    }
    catch {
        [PSCustomObject]@{ Computer = $pc; Profilo = "N/D"; Attivo = "NON RAGGIUNGIBILE: $_" }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$disattivati = ($risultati | Where-Object {$_.Attivo -eq $false}).Count
Write-Host "Controllati $($computer.Count) computer. Profili firewall disattivati trovati: $disattivati" -ForegroundColor $(if($disattivati -gt 0){"Red"}else{"Green"})
