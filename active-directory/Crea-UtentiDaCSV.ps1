<#
.SYNOPSIS
    Crea utenti Active Directory in blocco a partire da un file CSV.
.NOTES
    Il CSV deve avere le colonne: Nome;Cognome;Username;OU;Password;Reparto
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$PercorsoCSV,
    [switch]$Simula = $true
)

Import-Module ActiveDirectory

$utenti = Import-Csv -Path $PercorsoCSV -Delimiter ";"

foreach ($u in $utenti) {
    $nomeCompleto = "$($u.Nome) $($u.Cognome)"

    if (Get-ADUser -Filter "SamAccountName -eq '$($u.Username)'" -ErrorAction SilentlyContinue) {
        Write-Host "SALTATO: '$($u.Username)' esiste già." -ForegroundColor Yellow
        continue
    }

    if ($Simula) {
        Write-Host "SIMULAZIONE: verrebbe creato '$nomeCompleto' ($($u.Username)) in $($u.OU)" -ForegroundColor Cyan
        continue
    }

    try {
        New-ADUser -Name $nomeCompleto -GivenName $u.Nome -Surname $u.Cognome `
            -SamAccountName $u.Username `
            -UserPrincipalName "$($u.Username)@$((Get-ADDomain).DNSRoot)" `
            -Path $u.OU `
            -AccountPassword (ConvertTo-SecureString $u.Password -AsPlainText -Force) `
            -Department $u.Reparto -Enabled $true -ChangePasswordAtLogon $true

        Write-Host "CREATO: $nomeCompleto ($($u.Username))" -ForegroundColor Green
    }
    catch {
        Write-Host "ERRORE creando '$($u.Username)': $_" -ForegroundColor Red
    }
}
