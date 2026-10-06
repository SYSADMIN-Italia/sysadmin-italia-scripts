# SysAdmin Italia: script PowerShell gratuiti

Raccolta di **120 script PowerShell** per sistemisti, scritti in italiano e pensati per problemi reali: Active Directory, Windows Server, Microsoft 365, sicurezza, rete, VMware, database e automazione.

Ogni script ha una **guida dedicata su [sysadmin-italia.it](https://sysadmin-italia.it/script-gratuiti/)** con spiegazione, prerequisiti e PDF scaricabile.

## Categorie

| Categoria | Script |
|---|---|
| [Active Directory](active-directory/) | 14 |
| [Windows Server](windows-server/) | 16 |
| [Microsoft 365](microsoft-365/) | 16 |
| [Cyber Security](cyber-security/) | 16 |
| [Networking](networking/) | 14 |
| [VMware ESXi](vmware-esxi/) | 14 |
| [Database](database/) | 20 |
| [Automazione](automazione/) | 10 |

## Come usarli

1. Scarica il singolo file `.ps1` oppure clona il repository:
   ```powershell
   git clone https://github.com/SYSADMIN-Italia/sysadmin-italia-scripts.git
   ```
2. Se hai scaricato i file da Internet, sbloccali:
   ```powershell
   Get-ChildItem -Recurse -Filter *.ps1 | Unblock-File
   ```
3. Leggi l'intestazione dello script (`Get-Help .\NomeScript.ps1 -Full`) e i prerequisiti nella tabella della categoria.
4. **Provalo prima in un ambiente di test.** Gli script che modificano qualcosa vanno eseguiti la prima volta in modalità simulazione, dove prevista.

I file sono salvati in UTF-8 con BOM quando contengono caratteri accentati, così funzionano correttamente anche con Windows PowerShell 5.1.

Il repository si aggiorna automaticamente ogni settimana con gli script pubblicati sul sito.

## Contribuire

Hai trovato un bug o hai un miglioramento? Apri una *Issue* o una *Pull Request*. Le segnalazioni con l'errore completo e la versione di PowerShell (`$PSVersionTable`) sono le più utili.

## Licenza

Distribuiti con licenza [MIT](LICENSE): puoi usarli, modificarli e ridistribuirli liberamente, anche in azienda. Gli script sono forniti "così come sono", senza garanzie: verifica sempre cosa fanno prima di eseguirli in produzione.

---
A cura di Francesco Larossa · [sysadmin-italia.it](https://sysadmin-italia.it)