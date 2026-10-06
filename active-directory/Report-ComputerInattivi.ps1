<#
.SYNOPSIS
    Report dei computer Active Directory che non effettuano login da più di N giorni.
#>
param(
    [int]$GiorniSoglia = 90,
    [string]$PercorsoCSV = "C:\Report\ComputerInattivi.csv"
)

Import-Module ActiveDirectory

$dataLimite = (Get-Date).AddDays(-$GiorniSoglia)

$computer = Get-ADComputer -Filter {Enabled -eq $true} -Properties LastLogonDate, OperatingSystem, whenCreated |
    Where-Object { $_.LastLogonDate -lt $dataLimite -or -not $_.LastLogonDate }

$risultati = $computer | Select-Object Name,
    @{N="UltimoLogon";E={if($_.LastLogonDate){$_.LastLogonDate.ToString("dd/MM/yyyy")}else{"Mai registrato"}}},
    OperatingSystem,
    @{N="Creato";E={$_.whenCreated.ToString("dd/MM/yyyy")}}

$risultati | Sort-Object UltimoLogon | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Trovati $($risultati.Count) computer inattivi da oltre $GiorniSoglia giorni." -ForegroundColor Yellow
