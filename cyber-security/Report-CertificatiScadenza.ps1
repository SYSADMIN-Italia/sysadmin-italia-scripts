<#
.SYNOPSIS
    Controlla i certificati installati su più server, segnalando quelli in scadenza a breve.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaServer,
    [int]$GiorniAvviso = 30,
    [string]$PercorsoCSV = "C:\Report\CertificatiScadenza.csv"
)

$server = Get-Content -Path $ListaServer
$dataLimite = (Get-Date).AddDays($GiorniAvviso)

$risultati = foreach ($srv in $server) {
    try {
        $certs = Invoke-Command -ComputerName $srv -ScriptBlock {
            Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.NotAfter -lt (Get-Date).AddDays($using:GiorniAvviso) }
        } -ErrorAction Stop

        foreach ($c in $certs) {
            [PSCustomObject]@{
                Server        = $srv
                Soggetto      = $c.Subject
                Scadenza      = $c.NotAfter.ToString("dd/MM/yyyy")
                GiorniRimasti = ($c.NotAfter - (Get-Date)).Days
            }
        }
    }
    catch {
        [PSCustomObject]@{ Server = $srv; Soggetto = "N/D"; Scadenza = "N/D"; GiorniRimasti = "NON RAGGIUNGIBILE" }
    }
}

$risultati | Sort-Object GiorniRimasti | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) certificati in scadenza entro $GiorniAvviso giorni." -ForegroundColor Yellow
