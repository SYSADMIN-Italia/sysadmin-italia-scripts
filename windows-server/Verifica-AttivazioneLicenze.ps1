<#
.SYNOPSIS
    Verifica lo stato di attivazione della licenza Windows Server su un elenco di server.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaServer,
    [string]$PercorsoCSV = "C:\Report\AttivazioneLicenze.csv"
)

$server = Get-Content -Path $ListaServer

$risultati = foreach ($srv in $server) {
    try {
        $licenza = Get-CimInstance -ComputerName $srv -ClassName SoftwareLicensingProduct `
            -Filter "PartialProductKey IS NOT NULL AND ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f'" -ErrorAction Stop

        $stati = @{0="Non attivato"; 1="Attivato"; 2="Grazia iniziale"; 5="Notifica"}

        [PSCustomObject]@{
            Server = $srv
            Prodotto = $licenza.Name
            Stato = $stati[[int]$licenza.LicenseStatus]
        }
    }
    catch {
        [PSCustomObject]@{ Server = $srv; Prodotto = "N/D"; Stato = "NON RAGGIUNGIBILE" }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$problemi = ($risultati | Where-Object {$_.Stato -ne "Attivato"}).Count
Write-Host "Controllati $($server.Count) server. Con problemi di attivazione: $problemi" -ForegroundColor $(if($problemi -gt 0){"Red"}else{"Green"})
