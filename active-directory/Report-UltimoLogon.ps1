<#
.SYNOPSIS
    Esporta la data di ultimo accesso di tutti gli utenti del dominio.
.NOTES
    LastLogonDate si basa su lastLogonTimestamp, replicato tra i DC con una
    tolleranza di alcuni giorni: affidabile su base settimanale/mensile.
#>
param(
    [string]$PercorsoCSV = "C:\Report\UltimoLogonUtenti.csv"
)

Import-Module ActiveDirectory

$utenti = Get-ADUser -Filter * -Properties LastLogonDate, DisplayName, Enabled, Department

$risultati = $utenti | Select-Object DisplayName, SamAccountName, Department, Enabled,
    @{N="UltimoLogon";E={if($_.LastLogonDate){$_.LastLogonDate.ToString("dd/MM/yyyy")}else{"Mai"}}}

$risultati | Sort-Object UltimoLogon | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportati $($risultati.Count) utenti in: $PercorsoCSV" -ForegroundColor Green
