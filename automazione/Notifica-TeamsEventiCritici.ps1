<#
.SYNOPSIS
    Funzione riutilizzabile per inviare una notifica a un canale Microsoft Teams tramite webhook.
.NOTES
    Sostituisci $WebhookUrl con l'URL del connettore webhook configurato sul canale Teams.
#>
$WebhookUrl = "https://azienda.webhook.office.com/webhookb2/INSERISCI-IL-TUO-URL"

function Invia-NotificaTeams {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Titolo,
        [Parameter(Mandatory=$true)]
        [string]$Messaggio,
        [string]$Colore = "FF0000"
    )

    $payload = @{
        "@type"    = "MessageCard"
        "@context" = "http://schema.org/extensions"
        themeColor = $Colore
        title      = $Titolo
        text       = $Messaggio
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $payload -ContentType "application/json"
        Write-Host "Notifica inviata a Teams: $Titolo" -ForegroundColor Green
    }
    catch {
        Write-Host "Errore nell'invio della notifica a Teams: $_" -ForegroundColor Red
    }
}
