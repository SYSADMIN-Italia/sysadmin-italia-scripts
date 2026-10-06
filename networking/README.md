# Script PowerShell: Networking

14 script gratuiti. Ogni script ha una guida sul sito con spiegazione, parametri e PDF scaricabile.

| Script | Cosa fa | Prerequisiti | Guida |
|---|---|---|---|
| [`Verifica-CertificatiSSLDomini.ps1`](Verifica-CertificatiSSLDomini.ps1) | Verifica la data di scadenza del certificato SSL esposto da un elenco di domini pubblici. | Connettivita verso Internet sulla porta 443 | [Guida](https://sysadmin-italia.it/certificati-ssl-in-scadenza-su-piu-domini/) |
| [`Report-LeaseDHCPScadenza.ps1`](Report-LeaseDHCPScadenza.ps1) | Elenca i client con lease DHCP che scadranno entro un intervallo di tempo configurabile. | Modulo DhcpServer (RSAT), eseguito sul server DHCP | [Guida](https://sysadmin-italia.it/client-con-lease-dhcp-in-scadenza/) |
| [`Report-ScopeDHCP.ps1`](Report-ScopeDHCP.ps1) | Riepiloga tutti gli scope DHCP configurati con percentuale di utilizzo degli indirizzi disponibili. | Modulo DhcpServer (RSAT), eseguito sul server DHCP | [Guida](https://sysadmin-italia.it/configurazione-scope-dhcp-e-relativo-utilizzo/) |
| [`Report-IPDuplicati.ps1`](Report-IPDuplicati.ps1) | Esegue un ping sweep e confronta la tabella ARP per individuare possibili conflitti di indirizzo IP. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/dispositivi-con-ip-duplicato-rilevato-in-rete/) |
| [`Export-TabellaRouting.ps1`](Export-TabellaRouting.ps1) | Esporta la tabella di routing del sistema con interfacce e metriche in formato leggibile. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/export-tabella-di-routing-con-annotazioni/) |
| [`Test-LatenzaJitter.ps1`](Test-LatenzaJitter.ps1) | Misura latenza media e variabilita (jitter) verso un elenco di destinazioni. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/latenza-e-jitter-verso-piu-destinazioni/) |
| [`Monitor-UptimeHost.ps1`](Monitor-UptimeHost.ps1) | Esegue ping periodici verso un elenco di host, registrando su log ogni transizione di stato. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/monitoraggio-uptime-di-una-lista-di-host/) |
| [`Report-PorteInAscolto.ps1`](Report-PorteInAscolto.ps1) | Elenca tutte le porte TCP in ascolto su un server con il processo associato. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/porte-in-ascolto-su-un-server/) |
| [`Verifica-RecordDNS.ps1`](Verifica-RecordDNS.ps1) | Analizza una zona DNS alla ricerca di record duplicati o potenzialmente orfani. | Modulo DnsServer (RSAT), eseguito sul server DNS | [Guida](https://sysadmin-italia.it/record-dns-mancanti-o-duplicati/) |
| [`Scan-IPAttivi.ps1`](Scan-IPAttivi.ps1) | Esegue un ping sweep su una subnet, riportando gli indirizzi IP che rispondono. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/scanner-di-ip-attivi-su-una-subnet/) |
| [`Verifica-ServiziDNSCritici.ps1`](Verifica-ServiziDNSCritici.ps1) | Verifica che una lista di nomi DNS critici per l’infrastruttura si risolva correttamente. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/stato-dei-servizi-dns-critici/) |
| [`Test-ConnettivitaMultiHost.ps1`](Test-ConnettivitaMultiHost.ps1) | Testa la raggiungibilita di un elenco di host e produce un report riepilogativo. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/test-di-connettivita-verso-piu-host/) |
| [`Report-UtilizzoBanda.ps1`](Report-UtilizzoBanda.ps1) | Misura il traffico in entrata e uscita su ciascuna interfaccia di rete in un intervallo di tempo. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/utilizzo-banda-sulle-interfacce-di-rete/) |
| [`Test-VelocitaDNS.ps1`](Test-VelocitaDNS.ps1) | Misura quanto tempo impiega la risoluzione di un nome su piu server DNS diversi. | Nessuno, PowerShell nativo | [Guida](https://sysadmin-italia.it/velocita-di-risoluzione-dns/) |

[← Tutte le categorie](../README.md) · [SysAdmin Italia](https://sysadmin-italia.it/script-gratuiti/)