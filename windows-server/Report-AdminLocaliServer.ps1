<#
.SYNOPSIS
    Documenta i membri del gruppo Administrators locale su un elenco di server.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ListaServer,
    [string]$PercorsoCSV = "C:\Report\AdminLocaliServer.csv"
)

$server = Get-Content -Path $ListaServer

$risultati = foreach ($srv in $server) {
    try {
        $membri = Invoke-Command -ComputerName $srv -ScriptBlock {
            Get-LocalGroupMember -Group "Administrators" | Select-Object Name, ObjectClass
        } -ErrorAction Stop

        foreach ($m in $membri) {
            [PSCustomObject]@{ Server = $srv; Membro = $m.Name; Tipo = $m.ObjectClass }
        }
    }
    catch {
        [PSCustomObject]@{ Server = $srv; Membro = "N/D"; Tipo = "NON RAGGIUNGIBILE" }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Documentati $($server.Count) server." -ForegroundColor Green
