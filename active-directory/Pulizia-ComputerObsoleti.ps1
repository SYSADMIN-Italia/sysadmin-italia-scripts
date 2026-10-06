<#
.SYNOPSIS
    Disabilita automaticamente gli oggetti computer inattivi da più di N giorni.
    Per sicurezza, DISABILITA invece di eliminare.
#>
param(
    [int]$GiorniSoglia = 180,
    [switch]$Simula = $true,
    [string]$LogPath = "C:\Report\PuliziaComputer_Log.csv"
)

Import-Module ActiveDirectory

$dataLimite = (Get-Date).AddDays(-$GiorniSoglia)

$candidati = Get-ADComputer -Filter {Enabled -eq $true} -Properties LastLogonDate |
    Where-Object { $_.LastLogonDate -lt $dataLimite }

$log = foreach ($pc in $candidati) {
    if (-not $Simula) {
        Disable-ADAccount -Identity $pc.DistinguishedName
        $azione = "Disabilitato"
    } else {
        $azione = "SIMULAZIONE - sarebbe stato disabilitato"
    }

    [PSCustomObject]@{
        Computer       = $pc.Name
        UltimoLogon    = $pc.LastLogonDate
        Azione         = $azione
        DataEsecuzione = Get-Date -Format "dd/MM/yyyy HH:mm"
    }
}

$log | Export-Csv -Path $LogPath -NoTypeInformation -Encoding UTF8 -Delimiter ";" -Append
Write-Host "Elaborati $($log.Count) computer. Modalità simulazione: $Simula" -ForegroundColor $(if($Simula){"Yellow"}else{"Red"})
Write-Host "Per applicare le modifiche realmente, esegui con -Simula:`$false" -ForegroundColor Cyan
