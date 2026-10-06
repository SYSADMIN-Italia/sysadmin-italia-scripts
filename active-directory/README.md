# Script PowerShell: Active Directory

14 script gratuiti. Ogni script ha una guida sul sito con spiegazione, parametri e PDF scaricabile.

| Script | Cosa fa | Prerequisiti | Guida |
|---|---|---|---|
| [`Report-ComputerInattivi.ps1`](Report-ComputerInattivi.ps1) | Report dei computer che non effettuano login da tempo, primo passo prima di una pulizia. | Modulo ActiveDirectory (RSAT) | [Guida](https://sysadmin-italia.it/computer-inattivi-da-piu-di-n-giorni/) |
| [`Crea-UtentiDaCSV.ps1`](Crea-UtentiDaCSV.ps1) | Crea piu utenti contemporaneamente da un file CSV, con controllo duplicati e simulazione. | Modulo ActiveDirectory, permessi di creazione oggetti | [Guida](https://sysadmin-italia.it/creazione-utenti-in-blocco-da-csv/) |
| [`Report-DelegaNonVincolata.ps1`](Report-DelegaNonVincolata.ps1) | Individua account con delega Kerberos non vincolata, configurazione ad alto rischio. | Modulo ActiveDirectory | [Guida](https://sysadmin-italia.it/delega-kerberos-non-vincolata/) |
| [`Export-StrutturaOU.ps1`](Export-StrutturaOU.ps1) | Esporta tutte le OU del dominio con conteggio utenti e computer contenuti direttamente. | Modulo ActiveDirectory | [Guida](https://sysadmin-italia.it/export-struttura-completa-delle-ou/) |
| [`Report-GruppiVuoti.ps1`](Report-GruppiVuoti.ps1) | Individua i gruppi senza alcun membro, candidati a revisione o pulizia. | Modulo ActiveDirectory | [Guida](https://sysadmin-italia.it/gruppi-vuoti-o-inutilizzati/) |
| [`Report-ModificheGPO.ps1`](Report-ModificheGPO.ps1) | Elenca le Group Policy modificate negli ultimi N giorni. | Modulo GroupPolicy (RSAT) | [Guida](https://sysadmin-italia.it/modifiche-gpo-recenti/) |
| [`Pulizia-ComputerObsoleti.ps1`](Pulizia-ComputerObsoleti.ps1) | Disabilita (mai elimina) i computer inattivi da tempo, con modalita simulazione di default. | Modulo ActiveDirectory, permessi di scrittura | [Guida](https://sysadmin-italia.it/pulizia-automatica-computer-obsoleti/) |
| [`Report-SPNDuplicati.ps1`](Report-SPNDuplicati.ps1) | Individua Service Principal Name duplicati, causa comune di errori Kerberos. | Modulo ActiveDirectory | [Guida](https://sysadmin-italia.it/report-spn-duplicati/) |
| [`Reset-PasswordInBlocco.ps1`](Reset-PasswordInBlocco.ps1) | Reimposta la password per un elenco di utenti e invia le nuove credenziali via email. | Modulo ActiveDirectory, server SMTP raggiungibile | [Guida](https://sysadmin-italia.it/reset-password-in-blocco-con-notifica-email/) |
| [`Report-StatoReplica.ps1`](Report-StatoReplica.ps1) | Verifica lo stato di replica tra tutti i DC del dominio, evidenziando errori o DC irraggiungibili. | Modulo ActiveDirectory, connettivita verso i DC | [Guida](https://sysadmin-italia.it/stato-replica-tra-domain-controller/) |
| [`Report-UltimoLogon.ps1`](Report-UltimoLogon.ps1) | Esporta la data di ultimo accesso di ogni utente del dominio. | Modulo ActiveDirectory | [Guida](https://sysadmin-italia.it/ultimo-logon-di-tutti-gli-utenti/) |
| [`Report-UtentiSenzaManager.ps1`](Report-UtentiSenzaManager.ps1) | Individua utenti attivi con il campo Manager non valorizzato in Active Directory. | Modulo ActiveDirectory | [Guida](https://sysadmin-italia.it/utenti-senza-manager-assegnato/) |
| [`Verifica-RuoliFSMO.ps1`](Verifica-RuoliFSMO.ps1) | Mostra quali DC detengono i cinque ruoli FSMO e ne testa la raggiungibilita in tempo reale. | Modulo ActiveDirectory | [Guida](https://sysadmin-italia.it/verifica-salute-dei-ruoli-fsmo/) |
| [`Verifica-TrustAttivi.ps1`](Verifica-TrustAttivi.ps1) | Elenca tutti i trust configurati per il dominio e ne verifica lo stato di raggiungibilita. | Modulo ActiveDirectory, connettivita verso i domini in trust | [Guida](https://sysadmin-italia.it/verifica-trust-attivi/) |

[← Tutte le categorie](../README.md) · [SysAdmin Italia](https://sysadmin-italia.it/script-gratuiti/)