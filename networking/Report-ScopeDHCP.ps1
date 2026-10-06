<#
.SYNOPSIS
    Riepiloga tutti gli scope DHCP configurati con percentuale di utilizzo.
#>
param(
    [int]$SogliaAllarmePercento = 85,
    [string]$PercorsoCSV = "C:\Report\ScopeDHCP.csv"
)

Import-Module DhcpServer

$scope = Get-DhcpServerv4Scope

$risultati = foreach ($s in $scope) {
    $stats = Get-DhcpServerv4ScopeStatistics -ScopeId $s.ScopeId

    [PSCustomObject]@{
        Scope           = $s.Name
        Rete            = $s.ScopeId
        IndirizziTotali = $stats.Free + $stats.InUse
        IndirizziInUso  = $stats.InUse
        PercentualeUso  = [math]::Round($stats.PercentageInUse, 1)
        Allarme         = if ($stats.PercentageInUse -ge $SogliaAllarmePercento) {"SI"} else {"NO"}
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
$inAllarme = ($risultati | Where-Object {$_.Allarme -eq "SI"}).Count
Write-Host "Controllati $($scope.Count) scope. In allarme (oltre $SogliaAllarmePercento%): $inAllarme" -ForegroundColor $(if($inAllarme -gt 0){"Red"}else{"Green"})
