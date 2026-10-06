<#
.SYNOPSIS
    Recupera dal Default Trace gli eventi di autogrowth dei file database recenti.
#>
param(
    [string]$ServerSQL = "localhost",
    [int]$GiorniIndietro = 7,
    [string]$PercorsoCSV = "C:\Report\AutogrowthEventi.csv"
)
Import-Module SqlServer -ErrorAction SilentlyContinue

$query = @"
DECLARE @path NVARCHAR(260);
SELECT @path = REVERSE(SUBSTRING(REVERSE(path), CHARINDEX('\', REVERSE(path)), 260)) + N'log.trc'
FROM sys.traces WHERE is_default = 1;

SELECT DatabaseName, StartTime, Duration, EventSubClass
FROM ::fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (92, 93) AND StartTime > DATEADD(DAY, -$GiorniIndietro, GETDATE())
ORDER BY StartTime DESC
"@

$risultati = Invoke-Sqlcmd -ServerInstance $ServerSQL -Query $query
$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) eventi di autogrowth negli ultimi $GiorniIndietro giorni." -ForegroundColor Yellow
