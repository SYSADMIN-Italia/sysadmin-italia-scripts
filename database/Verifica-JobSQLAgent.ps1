<#
.SYNOPSIS
    Verifica l'esito dell'ultima esecuzione di ogni job di SQL Server Agent.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$PercorsoCSV = "C:\Report\JobSQLAgent.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT j.name AS NomeJob, j.enabled AS Abilitato,
       h.run_date, h.run_time, h.run_status
FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.sysjobhistory h ON h.job_id = j.job_id AND h.step_id = 0
WHERE h.instance_id = (SELECT MAX(instance_id) FROM msdb.dbo.sysjobhistory h2 WHERE h2.job_id = j.job_id AND h2.step_id = 0)
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query

$statoTesto = @{0="Fallito"; 1="Riuscito"; 3="Annullato"; 4="In corso"}
$report = $risultati | Select-Object NomeJob, Abilitato,
    @{N="UltimoEsito";E={$statoTesto[[int]$_.run_status]}}

$report | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$falliti = ($report | Where-Object {$_.UltimoEsito -eq "Fallito"}).Count
Write-Host "Controllati $($report.Count) job. Falliti nell'ultima esecuzione: $falliti" -ForegroundColor $(if($falliti -gt 0){"Red"}else{"Green"})
