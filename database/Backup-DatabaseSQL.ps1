<#
.SYNOPSIS
    Esegue un backup completo compresso di un database SQL Server specifico.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerSQL,
    [Parameter(Mandatory=$true)]
    [string]$NomeDatabase,
    [string]$CartellaBackup = "D:\Backup\SQL"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

if (-not (Test-Path $CartellaBackup)) { New-Item -Path $CartellaBackup -ItemType Directory -Force | Out-Null }

$nomeFile = "$NomeDatabase`_$(Get-Date -Format 'yyyyMMdd_HHmmss').bak"
$percorsoCompleto = Join-Path $CartellaBackup $nomeFile

$query = "BACKUP DATABASE [$NomeDatabase] TO DISK = N'$percorsoCompleto' WITH COMPRESSION, CHECKSUM"

try {
    Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query -QueryTimeout 0 -ErrorAction Stop
    Write-Host "Backup completato: $percorsoCompleto" -ForegroundColor Green
}
catch {
    Write-Host "Errore durante il backup: $_" -ForegroundColor Red
}
