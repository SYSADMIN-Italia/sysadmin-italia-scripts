<#
.SYNOPSIS
    Verifica i certificati nell'archivio locale del server, segnalando quelli in scadenza.
#>
param(
    [int]$GiorniAvviso = 30,
    [string]$PercorsoCSV = "C:\Report\CertificatiLocali.csv"
)

$dataLimite = (Get-Date).AddDays($GiorniAvviso)

$certificati = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.NotAfter -lt $dataLimite }

$risultati = $certificati | Select-Object Subject,
    @{N="Scadenza";E={$_.NotAfter.ToString("dd/MM/yyyy")}},
    @{N="GiorniRimasti";E={($_.NotAfter - (Get-Date)).Days}},
    Thumbprint

$risultati | Sort-Object GiorniRimasti | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) certificati in scadenza entro $GiorniAvviso giorni su $env:COMPUTERNAME." -ForegroundColor Yellow
