#Requires -Version 5.1

<#
.SYNOPSIS
    Elenca i computer del dominio con un sistema operativo fuori supporto o in scadenza.

.DESCRIPTION
    Legge da Active Directory sistema operativo, build e ultimo logon di ogni computer e li
    confronta con le date di fine supporto pubblicate da Microsoft (Microsoft Lifecycle).
    Per ogni computer indica prodotto, data di fine supporto, giorni rimanenti e stato:
      - Fuori supporto   : la data di fine supporto è già passata;
      - In scadenza      : mancano meno di GiorniPreavviso giorni;
      - Non classificato : sistema operativo o build non presenti nella tabella dello script;
      - Supportato       : mostrato solo con -IncludiSupportati.

    Di default esclude i computer disabilitati e quelli senza logon da più di
    GiorniInattivita giorni (o senza alcun logon), perché di solito sono oggetti
    obsoleti da pulire, non macchine da aggiornare.

    Lo script è in sola lettura: non modifica nulla in Active Directory.
    L'output è fatto di oggetti, quindi si esporta con Export-Csv; con
    -PercorsoReportHtml crea anche un report HTML.

    Date di fine supporto verificate su learn.microsoft.com/lifecycle il 10/10/2026.

.PARAMETER SearchBase
    OU da cui partire (DistinguishedName). Se omesso, tutto il dominio.

.PARAMETER Server
    Domain Controller da interrogare. Se omesso, quello scelto in automatico.

.PARAMETER GiorniInattivita
    Esclude i computer senza logon da più di questi giorni. 0 = non escludere nessuno.
    Default: 90.

.PARAMETER GiorniPreavviso
    Quanti giorni prima della fine supporto un sistema viene segnalato "In scadenza".
    Default: 180.

.PARAMETER IncludiSupportati
    Mostra anche i computer con un sistema operativo ancora supportato.

.PARAMETER IncludiDisabilitati
    Include anche gli account computer disabilitati.

.PARAMETER PercorsoReportHtml
    Se indicato, salva un report HTML in questo percorso.

.PARAMETER DataRiferimento
    Data rispetto a cui calcolare lo stato. Default: oggi. Utile per simulare
    "come sarà la situazione tra tre mesi".

.EXAMPLE
    .\Report-SistemiOperativiFuoriSupporto.ps1

    Elenca i computer attivi fuori supporto, in scadenza nei prossimi 180 giorni o non classificati.

.EXAMPLE
    .\Report-SistemiOperativiFuoriSupporto.ps1 -SearchBase 'OU=Server,DC=contoso,DC=local' -PercorsoReportHtml .\os-server.html

    Controlla solo la OU dei server e salva il report HTML.

.EXAMPLE
    .\Report-SistemiOperativiFuoriSupporto.ps1 -IncludiSupportati | Export-Csv .\inventario-os.csv -NoTypeInformation -Encoding UTF8

    Inventario completo di tutti i computer attivi, esportato in CSV.

.NOTES
    Autore    : Francesco Larossa - SysAdmin Italia (sysadmin-italia.it)
    Versione  : 1.0
    Data      : 10/10/2026
    Requisiti : Windows PowerShell 5.1 o PowerShell 7, modulo ActiveDirectory (RSAT),
                permesso di lettura sugli oggetti computer (basta un utente di dominio).
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$SearchBase,

    [Parameter()]
    [string]$Server,

    [Parameter()]
    [ValidateRange(0, 3650)]
    [int]$GiorniInattivita = 90,

    [Parameter()]
    [ValidateRange(1, 1095)]
    [int]$GiorniPreavviso = 180,

    [Parameter()]
    [switch]$IncludiSupportati,

    [Parameter()]
    [switch]$IncludiDisabilitati,

    [Parameter()]
    [string]$PercorsoReportHtml,

    [Parameter()]
    [datetime]$DataRiferimento = (Get-Date).Date
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Date di fine supporto (ultimo giorno coperto), fonte: Microsoft Lifecycle
# ---------------------------------------------------------------------------
$ServerPerNome = @(
    @{ Cerca = 'Windows Server 2025'; Prodotto = 'Windows Server 2025'; Fine = [datetime]'2034-11-14'; Nota = '' }
    @{ Cerca = 'Windows Server 2022'; Prodotto = 'Windows Server 2022'; Fine = [datetime]'2031-10-14'; Nota = 'Supporto esteso dal 14/10/2026' }
    @{ Cerca = 'Windows Server 2019'; Prodotto = 'Windows Server 2019'; Fine = [datetime]'2029-01-09'; Nota = '' }
    @{ Cerca = 'Windows Server 2016'; Prodotto = 'Windows Server 2016'; Fine = [datetime]'2027-01-12'; Nota = '' }
    @{ Cerca = 'Windows Server 2012'; Prodotto = 'Windows Server 2012 / 2012 R2'; Fine = [datetime]'2023-10-10'; Nota = 'ESU' }
    @{ Cerca = 'Windows Server 2008'; Prodotto = 'Windows Server 2008 / 2008 R2'; Fine = [datetime]'2020-01-14'; Nota = '' }
    @{ Cerca = 'Windows Server 2003'; Prodotto = 'Windows Server 2003'; Fine = [datetime]'2015-07-14'; Nota = '' }
)
$FineEsuServer2012 = [datetime]'2026-10-13'

# Windows 11: la versione si ricava dalla build (operatingSystemVersion, es. "10.0 (22631)")
$Win11Versioni = @{ 22000 = '21H2'; 22621 = '22H2'; 22631 = '23H2'; 26100 = '24H2'; 26200 = '25H2' }
$Win11EnterpriseEducation = @{
    22000 = [datetime]'2024-10-08'; 22621 = [datetime]'2025-10-14'; 22631 = [datetime]'2026-11-10'
    26100 = [datetime]'2027-10-12'; 26200 = [datetime]'2028-10-10'
}
$Win11HomePro = @{
    22000 = [datetime]'2023-10-10'; 22621 = [datetime]'2024-10-08'; 22631 = [datetime]'2025-11-11'
    26100 = [datetime]'2026-10-13'; 26200 = [datetime]'2027-10-12'
}
# Windows 10 LTSB/LTSC per build
$Win10Ltsc = @{
    14393 = @{ Prodotto = 'Windows 10 Enterprise LTSB 2016'; Fine = [datetime]'2026-10-13' }
    17763 = @{ Prodotto = 'Windows 10 Enterprise LTSC 2019'; Fine = [datetime]'2029-01-09' }
    19044 = @{ Prodotto = 'Windows 10 Enterprise LTSC 2021'; Fine = [datetime]'2027-01-12' }
}

function Get-InfoSupporto {
    # Restituisce prodotto, data di fine supporto e nota per un sistema operativo, oppure $null
    param([string]$SistemaOperativo, [int]$Build)
    $os = [string]$SistemaOperativo

    foreach ($r in $ServerPerNome) {
        if ($os -like "*$($r.Cerca)*") {
            $nota = $r.Nota
            if ($nota -eq 'ESU') {
                $nota = if ($DataRiferimento -le $FineEsuServer2012) { 'Aggiornamenti solo con ESU a pagamento, fino al 13/10/2026' } else { 'Anche gli ESU sono terminati il 13/10/2026' }
            }
            return @{ Prodotto = $r.Prodotto; Fine = $r.Fine; Nota = $nota }
        }
    }
    if ($os -like '*Windows 11*') {
        $enterprise = ($os -like '*Enterprise*') -or (($os -like '*Education*') -and ($os -notlike '*Pro Education*'))
        $tabella = if ($enterprise) { $Win11EnterpriseEducation } else { $Win11HomePro }
        $famiglia = if ($enterprise) { 'Enterprise/Education' } else { 'Home/Pro' }
        if ($tabella.ContainsKey($Build)) {
            return @{ Prodotto = "Windows 11 $famiglia $($Win11Versioni[$Build])"; Fine = $tabella[$Build]; Nota = '' }
        }
        return $null
    }
    if ($os -like '*Windows 10*') {
        if ($os -like '*IoT*') { return $null }   # IoT ha un ciclo di vita diverso
        if ($os -like '*LTSC*' -or $os -like '*LTSB*') {
            if ($Win10Ltsc.ContainsKey($Build)) { return @{ Prodotto = $Win10Ltsc[$Build].Prodotto; Fine = $Win10Ltsc[$Build].Fine; Nota = '' } }
            return $null
        }
        return @{ Prodotto = 'Windows 10'; Fine = [datetime]'2025-10-14'; Nota = 'ESU a pagamento disponibili' }
    }
    if ($os -like '*Windows 8.1*') { return @{ Prodotto = 'Windows 8.1'; Fine = [datetime]'2023-01-10'; Nota = '' } }
    if ($os -like '*Windows 7*') { return @{ Prodotto = 'Windows 7'; Fine = [datetime]'2020-01-14'; Nota = '' } }
    return $null
}

# ---------------------------------------------------------------------------
# Lettura da Active Directory
# ---------------------------------------------------------------------------
if (-not (Get-Command -Name Get-ADComputer -ErrorAction SilentlyContinue)) {
    try { Import-Module -Name ActiveDirectory -ErrorAction Stop }
    catch { throw 'Modulo ActiveDirectory non disponibile: installa gli strumenti RSAT (Active Directory Domain Services) o esegui lo script su un Domain Controller.' }
}

$parametri = @{
    Filter     = '*'
    Properties = @('OperatingSystem', 'OperatingSystemVersion', 'LastLogonDate', 'Enabled', 'DistinguishedName')
}
if ($SearchBase) { $parametri.SearchBase = $SearchBase }
if ($Server) { $parametri.Server = $Server }

try {
    $computer = @(Get-ADComputer @parametri)
}
catch {
    throw "Lettura dei computer da Active Directory non riuscita: $($_.Exception.Message)"
}

# ---------------------------------------------------------------------------
# Classificazione
# ---------------------------------------------------------------------------
$ordineStato = @{ 'Fuori supporto' = 0; 'In scadenza' = 1; 'Non classificato' = 2; 'Supportato' = 3 }
$esclusiDisabilitati = 0
$esclusiInattivi = 0
$risultati = New-Object System.Collections.Generic.List[object]

foreach ($c in $computer) {
    if (-not $IncludiDisabilitati -and -not $c.Enabled) { $esclusiDisabilitati++; continue }
    if ($GiorniInattivita -gt 0) {
        $inattivo = (-not $c.LastLogonDate) -or ($c.LastLogonDate -lt $DataRiferimento.AddDays(-$GiorniInattivita))
        if ($inattivo) { $esclusiInattivi++; continue }
    }

    $build = 0
    $m = [regex]::Match([string]$c.OperatingSystemVersion, '\((\d+)\)')
    if ($m.Success) { $build = [int]$m.Groups[1].Value }

    $info = Get-InfoSupporto -SistemaOperativo $c.OperatingSystem -Build $build
    if ($info) {
        $giorni = [int][math]::Floor(($info.Fine - $DataRiferimento).TotalDays)
        $stato = if ($giorni -lt 0) { 'Fuori supporto' } elseif ($giorni -le $GiorniPreavviso) { 'In scadenza' } else { 'Supportato' }
        $prodotto = $info.Prodotto
        $fine = $info.Fine
        $nota = $info.Nota
    }
    else {
        $giorni = $null
        $stato = 'Non classificato'
        $prodotto = ''
        $fine = $null
        $nota = if ($c.OperatingSystem) { "Sistema o build non in tabella: verifica su learn.microsoft.com/lifecycle" } else { 'Sistema operativo non registrato in AD' }
    }
    if ($stato -eq 'Supportato' -and -not $IncludiSupportati) { continue }

    $risultati.Add([pscustomobject]@{
        Nome              = $c.Name
        SistemaOperativo  = $c.OperatingSystem
        Build             = if ($build) { $build } else { $null }
        Prodotto          = $prodotto
        FineSupporto      = $fine
        GiorniRimanenti   = $giorni
        Stato             = $stato
        UltimoLogon       = $c.LastLogonDate
        Abilitato         = [bool]$c.Enabled
        Nota              = $nota
        DistinguishedName = $c.DistinguishedName
    })
}

$ordinati = @($risultati | Sort-Object -Property @{ Expression = { $ordineStato[$_.Stato] } }, @{ Expression = { if ($null -eq $_.GiorniRimanenti) { [int]::MaxValue } else { $_.GiorniRimanenti } } }, Nome)

$conteggi = $ordinati | Group-Object -Property Stato | ForEach-Object { '{0}: {1}' -f $_.Name, $_.Count }
$riepilogo = 'Analizzati {0} computer al {1:dd/MM/yyyy}. {2}. Esclusi: {3} disabilitati, {4} inattivi da più di {5} giorni.' -f `
    $computer.Count, $DataRiferimento, $(if ($conteggi) { $conteggi -join ', ' } else { 'Nessun computer da segnalare' }), $esclusiDisabilitati, $esclusiInattivi, $GiorniInattivita
Write-Information -MessageData $riepilogo -InformationAction Continue

# ---------------------------------------------------------------------------
# Report HTML (facoltativo)
# ---------------------------------------------------------------------------
if ($PercorsoReportHtml) {
    $enc = { param($t) [System.Net.WebUtility]::HtmlEncode([string]$t) }
    $colori = @{ 'Fuori supporto' = '#B3261E'; 'In scadenza' = '#C98A2C'; 'Non classificato' = '#5B6478'; 'Supportato' = '#2E7D4F' }
    $righe = foreach ($r in $ordinati) {
        $fineTesto = if ($r.FineSupporto) { $r.FineSupporto.ToString('dd/MM/yyyy') } else { '' }
        $logonTesto = if ($r.UltimoLogon) { ([datetime]$r.UltimoLogon).ToString('dd/MM/yyyy') } else { '' }
        '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td><span class="stato" style="background:{5}">{6}</span></td><td>{7}</td><td>{8}</td></tr>' -f `
            (& $enc $r.Nome), (& $enc $r.SistemaOperativo), (& $enc $r.Prodotto), $fineTesto, (& $enc $r.GiorniRimanenti), $colori[$r.Stato], (& $enc $r.Stato), $logonTesto, (& $enc $r.Nota)
    }
    $html = @"
<!DOCTYPE html>
<html lang="it"><head><meta charset="utf-8"><title>Sistemi operativi fuori supporto</title>
<style>
body{font-family:Manrope,Segoe UI,Arial,sans-serif;margin:0;background:#F4F6FA;color:#111C33}
header{background:#111C33;color:#fff;padding:24px 32px}header h1{margin:0;font-size:22px}
header p{margin:6px 0 0;color:#C8D3E6;font-size:14px}main{padding:24px 32px}
table{border-collapse:collapse;width:100%;background:#fff;font-size:13px}
th{background:#3E92CC;color:#fff;text-align:left;padding:8px}td{padding:7px 8px;border-bottom:1px solid #E1E6EF}
.stato{color:#fff;border-radius:4px;padding:2px 8px;white-space:nowrap}
footer{padding:16px 32px;color:#5B6478;font-size:12px}
</style></head><body>
<header><h1>Sistemi operativi fuori supporto o in scadenza</h1><p>$(& $enc $riepilogo)</p></header>
<main><table><thead><tr><th>Computer</th><th>Sistema operativo</th><th>Prodotto</th><th>Fine supporto</th><th>Giorni</th><th>Stato</th><th>Ultimo logon</th><th>Nota</th></tr></thead>
<tbody>
$($righe -join "`n")
</tbody></table></main>
<footer>Generato da Report-SistemiOperativiFuoriSupporto.ps1 - SysAdmin Italia (sysadmin-italia.it) - date di fine supporto: Microsoft Lifecycle</footer>
</body></html>
"@
    try {
        $html | Out-File -FilePath $PercorsoReportHtml -Encoding utf8
        Write-Information -MessageData "Report HTML salvato in $PercorsoReportHtml" -InformationAction Continue
    }
    catch {
        Write-Warning -Message "Report HTML non salvato: $($_.Exception.Message)"
    }
}

$ordinati
