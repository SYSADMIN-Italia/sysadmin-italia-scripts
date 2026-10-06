<#
.SYNOPSIS
    Reimposta la password per un elenco di utenti (da CSV) e invia una notifica email.
.NOTES
    Richiede un server SMTP configurato.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$PercorsoCSV,
    [string]$SmtpServer = "smtp.azienda.local",
    [string]$MittenteEmail = "it-support@azienda.local",
    [switch]$Simula = $true
)

Import-Module ActiveDirectory

$utenti = Import-Csv -Path $PercorsoCSV -Delimiter ";"

function New-PasswordCasuale {
    -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 12 | ForEach-Object {[char]$_}) + "!1"
}

foreach ($u in $utenti) {
    $nuovaPassword = New-PasswordCasuale

    if ($Simula) {
        Write-Host "SIMULAZIONE: reset password per '$($u.Username)', nuova password: $nuovaPassword" -ForegroundColor Cyan
        continue
    }

    try {
        Set-ADAccountPassword -Identity $u.Username -NewPassword (ConvertTo-SecureString $nuovaPassword -AsPlainText -Force) -Reset
        Set-ADUser -Identity $u.Username -ChangePasswordAtLogon $true

        $corpo = "Ciao,`n`nLa tua password è stata reimpostata. Nuova password temporanea: $nuovaPassword`n`nIT Support"
        Send-MailMessage -From $MittenteEmail -To $u.Email -Subject "Reset password account" -Body $corpo -SmtpServer $SmtpServer

        Write-Host "OK: password reimpostata e notificata per '$($u.Username)'" -ForegroundColor Green
    }
    catch {
        Write-Host "ERRORE per '$($u.Username)': $_" -ForegroundColor Red
    }
}
