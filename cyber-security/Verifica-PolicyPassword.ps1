<#
.SYNOPSIS
    Verifica se la password policy del dominio rispetta soglie minime di sicurezza consigliate.
#>
param(
    [string]$NomeFGPP = $null
)

Import-Module ActiveDirectory

if ($NomeFGPP) {
    $policy = Get-ADFineGrainedPasswordPolicy -Identity $NomeFGPP
} else {
    $policy = Get-ADDefaultDomainPasswordPolicy
}

$soglie = @{
    MinPasswordLength      = 12
    LockoutThreshold        = 5
    PasswordHistoryCount    = 12
}

Write-Host "=== Verifica Password Policy ===" -ForegroundColor Cyan

$check = @(
    @{Nome="Lunghezza minima"; Valore=$policy.MinPasswordLength; Soglia=$soglie.MinPasswordLength; Ok=($policy.MinPasswordLength -ge $soglie.MinPasswordLength)}
    @{Nome="Complessita richiesta"; Valore=$policy.ComplexityEnabled; Soglia=$true; Ok=($policy.ComplexityEnabled -eq $true)}
    @{Nome="Cronologia password"; Valore=$policy.PasswordHistoryCount; Soglia=$soglie.PasswordHistoryCount; Ok=($policy.PasswordHistoryCount -ge $soglie.PasswordHistoryCount)}
    @{Nome="Soglia blocco account"; Valore=$policy.LockoutThreshold; Soglia=$soglie.LockoutThreshold; Ok=($policy.LockoutThreshold -gt 0 -and $policy.LockoutThreshold -le $soglie.LockoutThreshold)}
)

foreach ($c in $check) {
    $colore = if ($c.Ok) {"Green"} else {"Red"}
    $esito = if ($c.Ok) {"OK"} else {"SOTTO SOGLIA CONSIGLIATA ($($c.Soglia))"}
    Write-Host ("{0,-25}: {1,-10} [{2}]" -f $c.Nome, $c.Valore, $esito) -ForegroundColor $colore
}
