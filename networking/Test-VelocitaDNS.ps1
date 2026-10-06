<#
.SYNOPSIS
    Misura il tempo di risoluzione di un nome su più server DNS diversi.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Nome,
    [Parameter(Mandatory=$true)]
    [string[]]$ServerDNS,
    [int]$Ripetizioni = 5
)

$risultati = foreach ($server in $ServerDNS) {
    $tempi = for ($i = 1; $i -le $Ripetizioni; $i++) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            Resolve-DnsName -Name $Nome -Server $server -ErrorAction Stop | Out-Null
            $sw.Stop()
            $sw.Elapsed.TotalMilliseconds
        }
        catch { $null }
    }
    $tempiValidi = $tempi | Where-Object { $_ -ne $null }

    [PSCustomObject]@{
        ServerDNS   = $server
        TempoMedioMs = if ($tempiValidi) { [math]::Round(($tempiValidi | Measure-Object -Average).Average, 1) } else { "N/D" }
        Fallimenti  = $Ripetizioni - $tempiValidi.Count
    }
}

$risultati | Sort-Object TempoMedioMs | Format-Table -AutoSize
