<#
.SYNOPSIS
    Elimina file temporanei e log più vecchi di una soglia configurabile.
#>
param(
    [Parameter(Mandatory=$true)]
    [string[]]$Percorsi,
    [int]$GiorniSoglia = 30,
    [switch]$Simula = $true,
    [string]$LogPath = "C:\Report\PuliziaFile_Log.csv"
)

$dataLimite = (Get-Date).AddDays(-$GiorniSoglia)

$log = foreach ($percorso in $Percorsi) {
    $file = Get-ChildItem -Path $percorso -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $dataLimite }

    foreach ($f in $file) {
        if (-not $Simula) {
            Remove-Item -Path $f.FullName -Force -ErrorAction SilentlyContinue
            $azione = "Eliminato"
        } else {
            $azione = "SIMULAZIONE - sarebbe stato eliminato"
        }

        [PSCustomObject]@{
            File         = $f.FullName
            DimensioneKB = [math]::Round($f.Length / 1KB, 1)
            UltimaModifica = $f.LastWriteTime
            Azione       = $azione
        }
    }
}

$log | Export-Csv -Path $LogPath -NoTypeInformation -Encoding UTF8 -Delimiter ";" -Append
$spazioLiberato = [math]::Round((($log | Measure-Object DimensioneKB -Sum).Sum) / 1024, 1)
Write-Host "Elaborati $($log.Count) file (circa $spazioLiberato MB). Modalita simulazione: $Simula" -ForegroundColor $(if($Simula){"Yellow"}else{"Green"})
