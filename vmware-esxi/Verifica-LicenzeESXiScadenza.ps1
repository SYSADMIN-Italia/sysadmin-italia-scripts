<#
.SYNOPSIS
    Confronta le licenze assegnate agli host con un elenco di scadenze tracciato manualmente.
.NOTES
    Il file CSV di riferimento deve avere le colonne: NomeHost;DataScadenza (formato dd/MM/yyyy)
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$FileScadenze,
    [int]$GiorniAvviso = 60
)

$scadenze = Import-Csv -Path $FileScadenze -Delimiter ";"
$host_esxi = Get-VMHost

$risultati = foreach ($riga in $scadenze) {
    $dataScadenza = [datetime]::ParseExact($riga.DataScadenza, "dd/MM/yyyy", $null)
    $giorniRimasti = ($dataScadenza - (Get-Date)).Days

    $hostEsiste = $host_esxi | Where-Object { $_.Name -eq $riga.NomeHost }

    [PSCustomObject]@{
        Host          = $riga.NomeHost
        HostPresente  = if ($hostEsiste) {"SI"} else {"NON TROVATO IN VCENTER"}
        Scadenza      = $riga.DataScadenza
        GiorniRimasti = $giorniRimasti
        Allarme       = if ($giorniRimasti -le $GiorniAvviso) {"SI"} else {"NO"}
    }
}

$risultati | Sort-Object GiorniRimasti | Format-Table -AutoSize
