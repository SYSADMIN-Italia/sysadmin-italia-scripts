<#
.SYNOPSIS
    Analizza una zona DNS alla ricerca di record duplicati.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$NomeZona,
    [string]$PercorsoCSV = "C:\Report\RecordDNSDuplicati.csv"
)

Import-Module DnsServer

$record = Get-DnsServerResourceRecord -ZoneName $NomeZona -RRType A

$perIP = $record | Group-Object { $_.RecordData.IPv4Address.ToString() } | Where-Object { $_.Count -gt 1 }

$risultati = foreach ($gruppo in $perIP) {
    [PSCustomObject]@{
        IndirizzoIP = $gruppo.Name
        NumeroNomi  = $gruppo.Count
        NomiHost    = ($gruppo.Group.HostName -join ", ")
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) indirizzi IP associati a piu nomi host nella zona $NomeZona." -ForegroundColor Yellow
