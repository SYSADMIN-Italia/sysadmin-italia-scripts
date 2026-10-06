<#
.SYNOPSIS
    Individua gli account guest che non accedono al tenant da tempo.
#>
param(
    [int]$GiorniSoglia = 90,
    [string]$PercorsoCSV = "C:\Report\GuestInattivi.csv"
)

Import-Module Microsoft.Graph.Users
Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All" -NoWelcome

$guest = Get-MgUser -Filter "userType eq 'Guest'" -All -Property DisplayName, Mail, SignInActivity, CreatedDateTime

$dataLimite = (Get-Date).AddDays(-$GiorniSoglia)

$risultati = $guest | Where-Object {
    -not $_.SignInActivity.LastSignInDateTime -or $_.SignInActivity.LastSignInDateTime -lt $dataLimite
} | Select-Object DisplayName, Mail,
    @{N="UltimoAccesso";E={if($_.SignInActivity.LastSignInDateTime){$_.SignInActivity.LastSignInDateTime}else{"Mai"}}},
    @{N="Creato";E={$_.CreatedDateTime}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) guest inattivi da oltre $GiorniSoglia giorni." -ForegroundColor Yellow
