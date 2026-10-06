<#
.SYNOPSIS
    Comprime più percorsi di configurazione in un unico archivio ZIP datato.
#>
param(
    [Parameter(Mandatory=$true)]
    [string[]]$Percorsi,
    [Parameter(Mandatory=$true)]
    [string]$CartellaDestinazione
)

if (-not (Test-Path $CartellaDestinazione)) {
    New-Item -Path $CartellaDestinazione -ItemType Directory -Force | Out-Null
}

$nomeArchivio = "BackupConfig_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
$percorsoArchivio = Join-Path $CartellaDestinazione $nomeArchivio

$percorsiValidi = $Percorsi | Where-Object { Test-Path $_ }
$percorsiMancanti = $Percorsi | Where-Object { -not (Test-Path $_) }

if ($percorsiMancanti) {
    Write-Host "Percorsi non trovati (saltati): $($percorsiMancanti -join ', ')" -ForegroundColor Yellow
}

Compress-Archive -Path $percorsiValidi -DestinationPath $percorsoArchivio -Force

Write-Host "Archivio creato: $percorsoArchivio ($($percorsiValidi.Count) percorsi inclusi)" -ForegroundColor Green
