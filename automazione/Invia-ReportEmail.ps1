<#
.SYNOPSIS
    Funzione riutilizzabile per inviare un file di report come allegato email.
.NOTES
    Personalizza SmtpServer e Mittente prima dell'uso, poi importa questo file
    (dot-sourcing: . .\Invia-ReportEmail.ps1) da altri script per usare la funzione.
#>
$SmtpServer = "smtp.azienda.local"
$Mittente = "reportistica-it@azienda.local"

function Invia-ReportViaEmail {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Destinatario,
        [Parameter(Mandatory=$true)]
        [string]$Oggetto,
        [Parameter(Mandatory=$true)]
        [string]$Allegato,
        [string]$Corpo = "In allegato il report richiesto, generato automaticamente."
    )

    if (-not (Test-Path $Allegato)) {
        Write-Host "File allegato non trovato: $Allegato" -ForegroundColor Red
        return
    }

    try {
        Send-MailMessage -From $Mittente -To $Destinatario -Subject $Oggetto -Body $Corpo `
            -Attachments $Allegato -SmtpServer $SmtpServer -Encoding UTF8

        Write-Host "Email inviata a $Destinatario con allegato $Allegato" -ForegroundColor Green
    }
    catch {
        Write-Host "Errore nell'invio email: $_" -ForegroundColor Red
    }
}
