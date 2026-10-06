<#
.SYNOPSIS
    Crea (o aggiorna) in locale il repository GitHub con tutti gli script gratuiti di sysadmin-italia.it.

.DESCRIPTION
    Legge l'elenco degli script dalla REST API pubblica del sito (nessuna credenziale necessaria),
    scarica ogni .ps1 nella cartella della sua categoria e genera:
      - README.md principale e un README.md per ogni categoria, con i link alle guide sul sito;
      - LICENSE (MIT) e .gitattributes.
    Gli script con caratteri accentati e senza BOM vengono salvati in UTF-8 con BOM,
    così Windows PowerShell 5.1 mostra correttamente le lettere accentate.
    Se git è installato, inizializza il repository e crea il commit.

    Rilancialo ogni volta che pubblichi nuovi script sul sito: aggiorna file e README,
    poi basta un commit e un push.

.EXAMPLE
    pwsh ./Crea-RepoScript.ps1
    pwsh ./Crea-RepoScript.ps1 -Destinazione ~/Progetti/sysadmin-italia-scripts -UtenteGitHub tuonome
#>
[CmdletBinding()]
param(
    [string]$Destinazione = (Join-Path (Get-Location) 'sysadmin-italia-scripts'),
    [string]$Sito = 'https://sysadmin-italia.it',
    [string]$Autore = 'Francesco Larossa',
    [string]$UtenteGitHub = '<tuo-utente>'
)

$ErrorActionPreference = 'Stop'

# ID categoria WordPress (sottocategorie di "Script Gratuiti") -> cartella e nome
$categorie = [ordered]@{
    '33' = @{ Cartella = 'active-directory'; Nome = 'Active Directory' }
    '38' = @{ Cartella = 'windows-server';   Nome = 'Windows Server' }
    '35' = @{ Cartella = 'microsoft-365';    Nome = 'Microsoft 365' }
    '34' = @{ Cartella = 'cyber-security';   Nome = 'Cyber Security' }
    '36' = @{ Cartella = 'networking';       Nome = 'Networking' }
    '37' = @{ Cartella = 'vmware-esxi';      Nome = 'VMware ESXi' }
    '40' = @{ Cartella = 'database';         Nome = 'Database' }
    '39' = @{ Cartella = 'automazione';      Nome = 'Automazione' }
}

# La cache nginx dell'hosting memorizza anche le risposte REST: parametro univoco per scavalcarla
function Get-NoCache { "_nc=$([guid]::NewGuid().ToString('N'))" }
function ConvertFrom-Html([string]$s) {
    if (-not $s) { return '' }
    [System.Net.WebUtility]::HtmlDecode(($s -replace '<[^>]+>', '')).Trim()
}
function Format-Cella([string]$s) { ($s -replace '\|', '\|' -replace '\r?\n', ' ').Trim() }
function Write-Utf8([string]$Percorso, [string]$Testo) {
    # README e file di testo: UTF-8 senza BOM, fine riga LF (standard GitHub)
    [IO.File]::WriteAllText($Percorso, ($Testo -replace "`r`n", "`n"), [Text.UTF8Encoding]::new($false))
}

New-Item -ItemType Directory -Force -Path $Destinazione | Out-Null
$Destinazione = (Resolve-Path $Destinazione).Path
Write-Host "Destinazione: $Destinazione" -ForegroundColor Cyan

$inventario = [System.Collections.Generic.List[object]]::new()
$errori = [System.Collections.Generic.List[string]]::new()

foreach ($idCat in $categorie.Keys) {
    $cat = $categorie[$idCat]
    $cartella = Join-Path $Destinazione $cat.Cartella
    New-Item -ItemType Directory -Force -Path $cartella | Out-Null

    $pagina = 1
    $post = @()
    do {
        $uri = "$Sito/wp-json/wp/v2/posts?categories=$idCat&per_page=100&page=$pagina&_fields=id,slug,title,content,link&$(Get-NoCache)"
        # Invoke-RestMethod in PowerShell 7 restituisce l'array JSON come un unico oggetto:
        # il ForEach-Object lo "srotola" negli elementi singoli
        $blocco = @(Invoke-RestMethod -Uri $uri -Headers @{ 'Cache-Control' = 'no-cache' } | ForEach-Object { $_ })
        $post += $blocco
        $pagina++
    } while ($blocco.Count -eq 100)

    Write-Host ("{0,-18} {1,3} script" -f $cat.Nome, $post.Count)

    foreach ($p in $post) {
        $html = $p.content.rendered
        $m = [regex]::Match($html, 'href="([^"]+\.ps1)"')
        if (-not $m.Success) { $errori.Add("Nessun .ps1 nella pagina $($p.link)"); continue }
        $urlScript = $m.Groups[1].Value
        $nomeFile = [IO.Path]::GetFileName(([uri]$urlScript).AbsolutePath)

        try {
            $tmp = [IO.Path]::GetTempFileName()
            Invoke-WebRequest -Uri "$urlScript`?$(Get-NoCache)" -OutFile $tmp -Headers @{ 'Cache-Control' = 'no-cache' }
            $byte = [IO.File]::ReadAllBytes($tmp)
            Remove-Item $tmp -Force
            $haBom = $byte.Length -ge 3 -and $byte[0] -eq 0xEF -and $byte[1] -eq 0xBB -and $byte[2] -eq 0xBF
            $nonAscii = [bool]($byte | Where-Object { $_ -gt 127 } | Select-Object -First 1)
            if (-not $haBom -and $nonAscii) {
                $byte = [byte[]](@(0xEF, 0xBB, 0xBF) + $byte)
            }
            [IO.File]::WriteAllBytes((Join-Path $cartella $nomeFile), $byte)
        }
        catch {
            $errori.Add("Download fallito: $urlScript ($($_.Exception.Message))")
            continue
        }

        $inventario.Add([pscustomobject]@{
            Categoria    = $cat.Nome
            Cartella     = $cat.Cartella
            File         = $nomeFile
            Titolo       = ConvertFrom-Html $p.title.rendered
            Descrizione  = ConvertFrom-Html ([regex]::Match($html, 'class="spd-lead">(.*?)</p>', 'Singleline').Groups[1].Value)
            Prerequisiti = ConvertFrom-Html ([regex]::Match($html, 'class="spd-meta-value">(.*?)</span>', 'Singleline').Groups[1].Value)
            Guida        = $p.link
        })
    }
}

# --- README per categoria ----------------------------------------------------
foreach ($cat in $categorie.Values) {
    $voci = $inventario | Where-Object Cartella -eq $cat.Cartella | Sort-Object Titolo
    $righe = foreach ($v in $voci) {
        "| [``$($v.File)``]($($v.File)) | $(Format-Cella $v.Descrizione) | $(Format-Cella $v.Prerequisiti) | [Guida]($($v.Guida)) |"
    }
    $testo = @"
# Script PowerShell: $($cat.Nome)

$($voci.Count) script gratuiti. Ogni script ha una guida sul sito con spiegazione, parametri e PDF scaricabile.

| Script | Cosa fa | Prerequisiti | Guida |
|---|---|---|---|
$($righe -join "`n")

[← Tutte le categorie](../README.md) · [SysAdmin Italia](https://sysadmin-italia.it/script-gratuiti/)
"@
    Write-Utf8 (Join-Path $Destinazione "$($cat.Cartella)/README.md") $testo
}

# --- README principale -------------------------------------------------------
$elencoCategorie = foreach ($cat in $categorie.Values) {
    $n = @($inventario | Where-Object Cartella -eq $cat.Cartella).Count
    "| [$($cat.Nome)]($($cat.Cartella)/) | $n |"
}
$readme = @"
# SysAdmin Italia: script PowerShell gratuiti

Raccolta di **$($inventario.Count) script PowerShell** per sistemisti, scritti in italiano e pensati per problemi reali: Active Directory, Windows Server, Microsoft 365, sicurezza, rete, VMware, database e automazione.

Ogni script ha una **guida dedicata su [sysadmin-italia.it](https://sysadmin-italia.it/script-gratuiti/)** con spiegazione, prerequisiti e PDF scaricabile.

## Categorie

| Categoria | Script |
|---|---|
$($elencoCategorie -join "`n")

## Come usarli

1. Scarica il singolo file ``.ps1`` oppure clona il repository:
   ``````powershell
   git clone https://github.com/$UtenteGitHub/sysadmin-italia-scripts.git
   ``````
2. Se hai scaricato i file da Internet, sbloccali:
   ``````powershell
   Get-ChildItem -Recurse -Filter *.ps1 | Unblock-File
   ``````
3. Leggi l'intestazione dello script (``Get-Help .\NomeScript.ps1 -Full``) e i prerequisiti nella tabella della categoria.
4. **Provalo prima in un ambiente di test.** Gli script che modificano qualcosa vanno eseguiti la prima volta in modalità simulazione, dove prevista.

I file sono salvati in UTF-8 con BOM quando contengono caratteri accentati, così funzionano correttamente anche con Windows PowerShell 5.1.

Il repository si aggiorna automaticamente ogni settimana con gli script pubblicati sul sito.

## Contribuire

Hai trovato un bug o hai un miglioramento? Apri una *Issue* o una *Pull Request*. Le segnalazioni con l'errore completo e la versione di PowerShell (```$PSVersionTable``) sono le più utili.

## Licenza

Distribuiti con licenza [MIT](LICENSE): puoi usarli, modificarli e ridistribuirli liberamente, anche in azienda. Gli script sono forniti "così come sono", senza garanzie: verifica sempre cosa fanno prima di eseguirli in produzione.

---
A cura di $Autore · [sysadmin-italia.it](https://sysadmin-italia.it)
"@
Write-Utf8 (Join-Path $Destinazione 'README.md') $readme

# --- LICENSE e .gitattributes -----------------------------------------------
Write-Utf8 (Join-Path $Destinazione 'LICENSE') @"
MIT License

Copyright (c) $((Get-Date).Year) $Autore

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@

Write-Utf8 (Join-Path $Destinazione '.gitattributes') @"
* text=auto
*.ps1 text eol=crlf
*.md text eol=lf
"@

# --- Riepilogo e git --------------------------------------------------------
Write-Host ""
Write-Host "Script scaricati: $($inventario.Count)" -ForegroundColor Green
if ($errori.Count) {
    Write-Host "Problemi: $($errori.Count)" -ForegroundColor Yellow
    $errori | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Push-Location $Destinazione
    try {
        if (-not (Test-Path .git)) { git init -b main | Out-Null }
        git add -A
        $modifiche = git status --porcelain
        if ($modifiche) {
            git commit -m "Sincronizzazione script da sysadmin-italia.it ($(Get-Date -Format 'yyyy-MM-dd'))" | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Commit creato. Ora pubblicalo su GitHub (vedi istruzioni)." -ForegroundColor Green
            }
            else {
                Write-Host "Commit NON creato: configura nome ed email di git (GitHub Desktop > Settings > Git) e rilancia lo script." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Nessuna modifica rispetto all'ultimo commit." -ForegroundColor Green
        }
    }
    finally { Pop-Location }
}
else {
    Write-Host "git non trovato: la cartella è pronta, il repository va inizializzato a mano o con GitHub Desktop." -ForegroundColor Yellow
}
