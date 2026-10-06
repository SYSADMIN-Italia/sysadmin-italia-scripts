# Script PowerShell: Automazione

10 script gratuiti. Ogni script ha una guida sul sito con spiegazione, parametri e PDF scaricabile.

| Script | Cosa fa | Prerequisiti | Guida |
|---|---|---|---|
| [`Backup-ConfigurazioniMultiple.ps1`](Backup-ConfigurazioniMultiple.ps1) | Comprime piu percorsi di configurazione in un unico archivio ZIP datato. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/backup-di-piu-configurazioni-in-un-unico-archivio/) |
| [`Confronta-SnapshotConfigurazione.ps1`](Confronta-SnapshotConfigurazione.ps1) | Confronta due esportazioni di configurazione dello stesso sistema effettuate in momenti diversi, evidenziando le differenze. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/confronto-configurazione-tra-due-snapshot-temporali/) |
| [`Dashboard-MultiSistema.ps1`](Dashboard-MultiSistema.ps1) | Mostra a console un riepilogo compatto e colorato dello stato di piu sistemi in un colpo d’occhio. | Connettivita verso i sistemi target | [Guida](https://sysadmin-italia.it/dashboard-testuale-riepilogativa-multi-sistema/) |
| [`Genera-InventarioHardwareSoftware.ps1`](Genera-InventarioHardwareSoftware.ps1) | Raccoglie specifiche hardware e software installato in un unico report per sistema. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/inventario-automatico-hardware-software/) |
| [`Invia-ReportEmail.ps1`](Invia-ReportEmail.ps1) | Funzione riutilizzabile per inviare un file di report come allegato email, pronta da richiamare da altri script. | Server SMTP raggiungibile | [Guida](https://sysadmin-italia.it/invio-automatico-di-report-via-email-con-allegato/) |
| [`Logging-CentralizzatoMultiServer.ps1`](Logging-CentralizzatoMultiServer.ps1) | Raccoglie eventi specifici da piu server in un unico file di log centralizzato. | Connettivita CIM/WMI verso i server target | [Guida](https://sysadmin-italia.it/logging-centralizzato-multi-server/) |
| [`Notifica-TeamsEventiCritici.ps1`](Notifica-TeamsEventiCritici.ps1) | Invia una notifica su un canale Microsoft Teams tramite webhook quando viene rilevato un evento critico. | Un connettore webhook in ingresso configurato sul canale Teams | [Guida](https://sysadmin-italia.it/notifica-su-teams-per-eventi-critici-rilevati/) |
| [`Archivia-LogApplicativiDatati.ps1`](Archivia-LogApplicativiDatati.ps1) | Comprime i log applicativi piu vecchi di una soglia invece di eliminarli, liberando spazio ma mantenendo lo storico. | Permessi di scrittura sui percorsi target | [Guida](https://sysadmin-italia.it/pulizia-archiviazione-log-applicativi-datati/) |
| [`Genera-ReportHTMLGiornaliero.ps1`](Genera-ReportHTMLGiornaliero.ps1) | Combina piu controlli (disco, servizi, uptime) in un unico report HTML colorato e leggibile. | Connettivita verso i server target | [Guida](https://sysadmin-italia.it/report-html-giornaliero-sullo-stato-dellinfrastruttura/) |
| [`Verifica-SaluteInfrastruttura.ps1`](Verifica-SaluteInfrastruttura.ps1) | Esegue una serie combinata di controlli rapidi (rete, disco, servizi) e produce un esito complessivo pass/fail. | Connettivita verso i sistemi target | [Guida](https://sysadmin-italia.it/verifica-generale-salute-infrastruttura/) |

[← Tutte le categorie](../README.md) · [SysAdmin Italia](https://sysadmin-italia.it/script-gratuiti/)