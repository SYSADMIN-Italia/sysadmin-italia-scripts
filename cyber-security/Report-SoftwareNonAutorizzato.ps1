<#
.SYNOPSIS
    Confronta il software installato su un computer con una whitelist, segnalando ogni eccezione.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Whitelist,
    [string]$PercorsoCSV = "C:\Report\SoftwareNonAutorizzato.csv"
)

$whitelistArray = Get-Content -Path $Whitelist

$chiaviRegistro = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$softwareInstallato = Get-ItemProperty $chiaviRegistro -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher -Unique

$nonAutorizzato = $softwareInstallato | Where-Object {
    $nome = $_.DisplayName
    -not ($whitelistArray | Where-Object { $nome -like "*$_*" })
}

$nonAutorizzato | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($nonAutorizzato.Count) software non presenti in whitelist su $env:COMPUTERNAME." -ForegroundColor Yellow
