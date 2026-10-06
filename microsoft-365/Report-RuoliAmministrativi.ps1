<#
.SYNOPSIS
    Elenca tutti gli utenti assegnati a ruoli con privilegi amministrativi nel tenant.
#>
param(
    [string]$PercorsoCSV = "C:\Report\RuoliAmministrativi.csv"
)

Import-Module Microsoft.Graph.Identity.DirectoryManagement
Connect-MgGraph -Scopes "RoleManagement.Read.Directory" -NoWelcome

$ruoli = Get-MgDirectoryRole

$risultati = foreach ($r in $ruoli) {
    $membri = Get-MgDirectoryRoleMember -DirectoryRoleId $r.Id
    foreach ($m in $membri) {
        [PSCustomObject]@{
            Ruolo  = $r.DisplayName
            Utente = $m.AdditionalProperties["displayName"]
        }
    }
}

$risultati | Sort-Object Ruolo | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportati $($risultati.Count) assegnamenti di ruoli amministrativi." -ForegroundColor Green
