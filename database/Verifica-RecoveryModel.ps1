<#
.SYNOPSIS
    Verifica la modalità di recovery configurata su ogni database dell'istanza.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$PercorsoCSV = "C:\Report\RecoveryModel.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = "SELECT name AS NomeDatabase, recovery_model_desc AS ModalitaRecovery FROM sys.databases WHERE database_id > 4"
$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Verificata la modalita di recovery di $($risultati.Count) database." -ForegroundColor Green
