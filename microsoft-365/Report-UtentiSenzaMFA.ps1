<#
.SYNOPSIS
    Individua gli utenti che non hanno alcun metodo di autenticazione a più fattori registrato.
#>
param(
    [string]$PercorsoCSV = "C:\Report\UtentiSenzaMFA.csv"
)

Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.SignIns
Connect-MgGraph -Scopes "User.Read.All", "UserAuthenticationMethod.Read.All" -NoWelcome

$utenti = Get-MgUser -All -Filter "accountEnabled eq true"

$risultati = foreach ($u in $utenti) {
    $metodi = Get-MgUserAuthenticationMethod -UserId $u.Id
    $soloPassword = ($metodi | Where-Object { $_.AdditionalProperties["@odata.type"] -ne "#microsoft.graph.passwordAuthenticationMethod" }).Count -eq 0

    if ($soloPassword) {
        [PSCustomObject]@{
            Utente = $u.UserPrincipalName
            Nome   = $u.DisplayName
        }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) utenti senza MFA configurato." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
