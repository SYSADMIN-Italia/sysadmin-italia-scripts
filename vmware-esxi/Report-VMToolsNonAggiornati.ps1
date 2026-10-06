<#
.SYNOPSIS
    Individua le macchine virtuali con VMware Tools non aggiornati o non in esecuzione.
#>
param(
    [string]$PercorsoCSV = "C:\Report\VMToolsNonAggiornati.csv"
)

$vm = Get-VM | Where-Object { $_.PowerState -eq "PoweredOn" }

$risultati = foreach ($v in $vm) {
    $toolsStatus = $v.ExtensionData.Guest.ToolsStatus
    if ($toolsStatus -ne "toolsOk") {
        [PSCustomObject]@{
            VM          = $v.Name
            StatoTools  = $toolsStatus
            VersioneOS  = $v.Guest.OSFullName
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) VM con VMware Tools da aggiornare o verificare." -ForegroundColor Yellow
