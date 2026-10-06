<#
.SYNOPSIS
    Verifica lo stato di sincronizzazione delle repliche in un Always On Availability Group.
#>
param(
    [string]$ServerSQL = "localhost",
    [string]$PercorsoCSV = "C:\Report\AlwaysOnAG.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
SELECT ag.name AS NomeAG, ar.replica_server_name AS Replica,
       ars.role_desc AS Ruolo, ars.synchronization_health_desc AS StatoSync
FROM sys.availability_groups ag
JOIN sys.availability_replicas ar ON ar.group_id = ag.group_id
JOIN sys.dm_hadr_availability_replica_states ars ON ars.replica_id = ar.replica_id
"@

try {
    $risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query -ErrorAction Stop
    $risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
    $problemi = ($risultati | Where-Object {$_.StatoSync -ne "HEALTHY"}).Count
    Write-Host "Controllate $($risultati.Count) repliche. Non in salute: $problemi" -ForegroundColor $(if($problemi -gt 0){"Red"}else{"Green"})
}
catch {
    Write-Host "Always On non configurato su questa istanza, o errore: $_" -ForegroundColor Yellow
}
