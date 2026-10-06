<#
.SYNOPSIS
    Comprime i log applicativi più vecchi di una soglia invece di eliminarli.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$PercorsoLog,
    [int]$GiorniSoglia = 60,
    [string]$CartellaArchivio = "D:\App\LogArchiviati"
)

if (-not (Test-Path $CartellaArchivio)) { New-Item -Path $CartellaArchivio -ItemType Directory -Force | Out-Null }

$dataLimite = (Get-Date).AddDays(-$GiorniSoglia)
$file = Get-ChildItem -Path $PercorsoLog -Filter "*.log" -File | Where-Object { $_.LastWriteTime -lt $dataLimite }

$perMese = $file | Group-Object { $_.LastWriteTime.ToString("yyyy-MM") }

foreach ($gruppo in $perMese) {
    $nomeArchivio = Join-Path $CartellaArchivio "Log_$($gruppo.Name).zip"
    Compress-Archive -Path $gruppo.Group.FullName -DestinationPath $nomeArchivio -Update

    if (Test-Path $nomeArchivio) {
        $gruppo.Group | Remove-Item -Force
        Write-Host "Archiviati $($gruppo.Count) log di $($gruppo.Name) in $nomeArchivio" -ForegroundColor Green
    }
}

Write-Host "Archiviazione completata." -ForegroundColor Green
