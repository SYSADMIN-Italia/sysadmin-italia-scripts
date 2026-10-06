<#
.SYNOPSIS
    Individua gli account di servizio (con SPN associato) con password non scadente.
#>
param(
    [string]$PercorsoCSV = "C:\Report\ServiziPasswordNonScadente.csv"
)

Import-Module ActiveDirectory

$account = Get-ADUser -Filter {ServicePrincipalName -like "*" -and PasswordNeverExpires -eq $true} `
    -Properties ServicePrincipalName, PasswordLastSet, DisplayName

$risultati = $account | Select-Object DisplayName, SamAccountName,
    @{N="PasswordImpostataIl";E={if($_.PasswordLastSet){$_.PasswordLastSet.ToString("dd/MM/yyyy")}else{"Mai"}}},
    @{N="GiorniDaUltimoCambio";E={if($_.PasswordLastSet){((Get-Date) - $_.PasswordLastSet).Days}else{"N/D"}}},
    @{N="NumeroSPN";E={$_.ServicePrincipalName.Count}}

$risultati | Sort-Object GiorniDaUltimoCambio -Descending | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) account di servizio con password non scadente." -ForegroundColor Yellow
