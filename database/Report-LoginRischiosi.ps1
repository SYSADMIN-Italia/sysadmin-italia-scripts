<#
.SYNOPSIS
    Verifica se l'account 'sa' è attivo e quali login SQL hanno la password scaduta.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$PercorsoCSV = "C:\Report\LoginRischiosi.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT name AS Login, is_disabled AS Disabilitato,
       CASE WHEN name = 'sa' AND is_disabled = 0 THEN 1 ELSE 0 END AS SAAttivo,
       LOGINPROPERTY(name, 'IsExpired') AS PasswordScaduta
FROM sys.sql_logins
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$saAttivo = ($risultati | Where-Object {$_.SAAttivo -eq 1}).Count
Write-Host "Controllati $($risultati.Count) login SQL. Account 'sa' attivo: $(if($saAttivo -gt 0){'SI - da verificare'}else{'NO'})" -ForegroundColor $(if($saAttivo -gt 0){"Red"}else{"Green"})
