<#
.SYNOPSIS
    Verifica lo stato di replica tra tutti i Domain Controller del dominio.
#>
param(
    [string]$PercorsoCSV = "C:\Report\StatoReplica.csv"
)

Import-Module ActiveDirectory

$dc = Get-ADDomainController -Filter *

$risultati = foreach ($server in $dc) {
    try {
        $repliche = Get-ADReplicationPartnerMetadata -Target $server.HostName -ErrorAction Stop

        foreach ($rep in $repliche) {
            [PSCustomObject]@{
                DomainController = $server.HostName
                Partner          = $rep.Partner
                UltimaReplica    = $rep.LastReplicationSuccess
                UltimoTentativo  = $rep.LastReplicationAttempt
                UltimoErrore     = $rep.LastReplicationResult
                Stato            = if ($rep.LastReplicationResult -eq 0) {"OK"} else {"ERRORE"}
            }
        }
    }
    catch {
        [PSCustomObject]@{
            DomainController = $server.HostName
            Partner           = "N/D"
            UltimaReplica     = "N/D"
            UltimoTentativo   = "N/D"
            UltimoErrore      = "Impossibile contattare il DC: $_"
            Stato             = "NON RAGGIUNGIBILE"
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$errori = ($risultati | Where-Object {$_.Stato -ne "OK"}).Count
Write-Host "Report generato. Repliche con problemi: $errori" -ForegroundColor $(if($errori -gt 0){"Red"}else{"Green"})
