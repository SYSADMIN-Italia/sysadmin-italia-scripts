<#
.SYNOPSIS
    Verifica quali database non hanno un backup completo recente.
#>
param(
    [string]$ServerSQL = "localhost",
    [int]$OreSogliaFull = 24,
    [string]$PercorsoCSV = "C:\Report\BackupSQLScaduti.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT d.name AS NomeDatabase,
       MAX(b.backup_finish_date) AS UltimoBackupFull
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b ON b.database_name = d.name AND b.type = 'D'
WHERE d.database_id > 4
GROUP BY d.name
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query

$report = foreach ($r in $risultati) {
    $oreDaUltimoBackup = if ($r.UltimoBackupFull) { ((Get-Date) - $r.UltimoBackupFull).TotalHours } else { 999999 }
    [PSCustomObject]@{
        Database = $r.NomeDatabase
        UltimoBackupFull = if ($r.UltimoBackupFull) { $r.UltimoBackupFull } else { "MAI" }
        OreFa = [math]::Round($oreDaUltimoBackup, 1)
        Allarme = if ($oreDaUltimoBackup -gt $OreSogliaFull) { "SI" } else { "NO" }
    }
}

$report | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$inAllarme = ($report | Where-Object {$_.Allarme -eq "SI"}).Count
Write-Host "Controllati $($report.Count) database. Senza backup recente: $inAllarme" -ForegroundColor $(if($inAllarme -gt 0){"Red"}else{"Green"})
