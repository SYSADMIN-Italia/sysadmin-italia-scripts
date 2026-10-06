<#
.SYNOPSIS
    Report dei gruppi Active Directory senza alcun membro.
#>
param(
    [string]$PercorsoCSV = "C:\Report\GruppiVuoti.csv"
)

Import-Module ActiveDirectory

$gruppi = Get-ADGroup -Filter * -Properties Description, whenCreated

$risultati = foreach ($g in $gruppi) {
    $membri = Get-ADGroupMember -Identity $g.DistinguishedName -ErrorAction SilentlyContinue
    if (-not $membri -or $membri.Count -eq 0) {
        [PSCustomObject]@{
            NomeGruppo  = $g.Name
            Descrizione = $g.Description
            Creato      = $g.whenCreated.ToString("dd/MM/yyyy")
            Percorso    = $g.DistinguishedName
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) gruppi senza membri." -ForegroundColor Yellow
