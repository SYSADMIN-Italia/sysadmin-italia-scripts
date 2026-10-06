<#
.SYNOPSIS
    Misura latenza media e jitter verso un elenco di destinazioni.
#>
param(
    [Parameter(Mandatory=$true)]
    [string[]]$Destinazioni,
    [int]$NumeroPing = 20,
    [string]$PercorsoCSV = "C:\Report\LatenzaJitter.csv"
)

$risultati = foreach ($dest in $Destinazioni) {
    $test = Test-Connection -ComputerName $dest -Count $NumeroPing -ErrorAction SilentlyContinue

    if ($test) {
        $tempi = $test.ResponseTime
        $media = ($tempi | Measure-Object -Average).Average
        $varianza = ($tempi | ForEach-Object { [math]::Pow($_ - $media, 2) } | Measure-Object -Average).Average
        $jitter = [math]::Sqrt($varianza)

        [PSCustomObject]@{
            Destinazione  = $dest
            LatenzaMediaMs = [math]::Round($media, 1)
            JitterMs      = [math]::Round($jitter, 1)
            PacchettiPersi = $NumeroPing - $test.Count
        }
    } else {
        [PSCustomObject]@{ Destinazione = $dest; LatenzaMediaMs = "N/D"; JitterMs = "N/D"; PacchettiPersi = $NumeroPing }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Testate $($Destinazioni.Count) destinazioni." -ForegroundColor Green
