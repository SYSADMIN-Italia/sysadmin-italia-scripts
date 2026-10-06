<#
.SYNOPSIS
    Verifica quali Domain Controller detengono i cinque ruoli FSMO e ne testa la raggiungibilità.
#>

Import-Module ActiveDirectory

$forest = Get-ADForest
$domain = Get-ADDomain

$ruoli = [PSCustomObject]@{
    SchemaMaster         = $forest.SchemaMaster
    DomainNamingMaster   = $forest.DomainNamingMaster
    PDCEmulator          = $domain.PDCEmulator
    RIDMaster            = $domain.RIDMaster
    InfrastructureMaster = $domain.InfrastructureMaster
}

Write-Host "=== Ruoli FSMO attuali ===" -ForegroundColor Cyan
foreach ($ruolo in $ruoli.PSObject.Properties) {
    $server = $ruolo.Value
    $raggiungibile = Test-Connection -ComputerName $server -Count 1 -Quiet

    $colore = if ($raggiungibile) {"Green"} else {"Red"}
    $stato = if ($raggiungibile) {"OK"} else {"NON RAGGIUNGIBILE"}

    Write-Host ("{0,-25}: {1,-30} [{2}]" -f $ruolo.Name, $server, $stato) -ForegroundColor $colore
}
