<#
.SYNOPSIS
    Individua le attività pianificate la cui ultima esecuzione è terminata con un codice di errore.
#>
param(
    [string]$PercorsoCSV = "C:\Report\TaskSchedulerErrori.csv"
)

$task = Get-ScheduledTask | Where-Object { $_.State -ne "Disabled" }

$risultati = foreach ($t in $task) {
    $info = $t | Get-ScheduledTaskInfo

    if ($info.LastTaskResult -ne 0) {
        [PSCustomObject]@{
            Nome            = $t.TaskName
            Percorso        = $t.TaskPath
            UltimaEsecuzione = $info.LastRunTime
            CodiceErrore    = $info.LastTaskResult
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) attivita pianificate terminate con errore." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
