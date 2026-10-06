<#
.SYNOPSIS
    Analizza il log di sicurezza per individuare pattern di tentativi di accesso falliti ripetuti.
#>
param(
    [int]$OreIndietro = 24,
    [int]$SogliaTentativi = 10,
    [string]$PercorsoCSV = "C:\Report\LoginFalliti.csv"
)

$dataLimite = (Get-Date).AddHours(-$OreIndietro)

$eventi = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=$dataLimite} -ErrorAction SilentlyContinue

$raggruppati = $eventi | ForEach-Object {
    $xml = [xml]$_.ToXml()
    $dati = $xml.Event.EventData.Data
    [PSCustomObject]@{
        Account = ($dati | Where-Object {$_.Name -eq 'TargetUserName'}).'#text'
        IPOrigine = ($dati | Where-Object {$_.Name -eq 'IpAddress'}).'#text'
        Orario = $_.TimeCreated
    }
} | Group-Object Account, IPOrigine | Where-Object { $_.Count -ge $SogliaTentativi }

$risultati = $raggruppati | Select-Object @{N="AccountEIP";E={$_.Name}}, Count,
    @{N="PrimoTentativo";E={($_.Group | Sort-Object Orario | Select-Object -First 1).Orario}},
    @{N="UltimoTentativo";E={($_.Group | Sort-Object Orario -Descending | Select-Object -First 1).Orario}}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovate $($risultati.Count) combinazioni account/IP con oltre $SogliaTentativi tentativi falliti." -ForegroundColor $(if($risultati.Count -gt 0){"Red"}else{"Green"})
