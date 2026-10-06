<#
.SYNOPSIS
    Raccoglie specifiche hardware e software installato in un unico report.
#>
param(
    [string]$CartellaOutput = "C:\Report"
)

if (-not (Test-Path $CartellaOutput)) { New-Item -Path $CartellaOutput -ItemType Directory -Force | Out-Null }

# --- Hardware ---
$cpu = Get-CimInstance Win32_Processor
$ram = Get-CimInstance Win32_PhysicalMemory
$dischi = Get-CimInstance Win32_DiskDrive

$hardware = [PSCustomObject]@{
    Computer      = $env:COMPUTERNAME
    Processore    = $cpu.Name
    NumeroCore    = $cpu.NumberOfCores
    RAMTotaleGB   = [math]::Round((($ram | Measure-Object Capacity -Sum).Sum) / 1GB, 1)
    NumeroDischi  = $dischi.Count
    DimensioneDischiGB = ($dischi | ForEach-Object { [math]::Round($_.Size / 1GB, 1) }) -join ", "
}
$hardware | Export-Csv -Path "$CartellaOutput\Hardware_$env:COMPUTERNAME.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"

# --- Software ---
$chiaviRegistro = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$software = Get-ItemProperty $chiaviRegistro -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher -Unique
$software | Export-Csv -Path "$CartellaOutput\Software_$env:COMPUTERNAME.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"

Write-Host "Inventario hardware e software generato in: $CartellaOutput" -ForegroundColor Green
