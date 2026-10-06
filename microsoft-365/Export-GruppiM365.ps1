<#
.SYNOPSIS
    Esporta tutti i gruppi Microsoft 365 del tenant con l'elenco completo dei membri.
#>
param(
    [string]$PercorsoCSV = "C:\Report\GruppiM365.csv"
)

Import-Module Microsoft.Graph.Groups
Connect-MgGraph -Scopes "Group.Read.All" -NoWelcome

$gruppi = Get-MgGroup -Filter "groupTypes/any(c:c eq 'Unified')" -All

$risultati = foreach ($g in $gruppi) {
    $membri = Get-MgGroupMember -GroupId $g.Id -All
    foreach ($m in $membri) {
        [PSCustomObject]@{
            Gruppo = $g.DisplayName
            Membro = $m.AdditionalProperties["displayName"]
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Esportati $($gruppi.Count) gruppi con relativi membri in: $PercorsoCSV" -ForegroundColor Green
