<#
.SYNOPSIS
    Elenca i Maintenance Plan configurati sull'istanza con l'esito dell'ultima esecuzione.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$PercorsoCSV = "C:\Report\MaintenancePlan.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT sp.name AS NomePiano, sp.description AS Descrizione,
       h.run_date, h.run_status
FROM msdb.dbo.sysmaintplan_plans sp
LEFT JOIN msdb.dbo.sysjobs j ON j.name LIKE '%' + sp.name + '%'
LEFT JOIN msdb.dbo.sysjobhistory h ON h.job_id = j.job_id AND h.step_id = 0
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) Maintenance Plan configurati." -ForegroundColor Green
