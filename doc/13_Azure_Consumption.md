# Azure Consumption

[[_TOC_]]

Die Berechnung der Azure Consumption für die Data Platform kann durchaus komplex werden. Nicht nur die genutzten Services sondern auch das Datenvolumen und die Laufzeit der Datenintegration muss beachtet werden.

Anhand des nachfolgenden Szenarios wird die Azure Consumption beispielhaft berechnet.

> Alle Services werden in der Region Westeuropa aufgebaut. Bei der Datenintegration wird der Monat 12 betrachtet, d.h., in die Azure Storage Accounts, die Azure SQL Datenbank und Dedizierten SQL Pool von Azure Synapse sind bereits Daten der vorherigen 11 Monate gespeichert.

## Datenintegration

* Der Einfachheit halber gehen wir von einer Datenquelle aus, die angebunden wird.
* Es wird eine Delta-Datei von 250 MB Größe pro Stunde verarbeitet.
  * Die Dateien werden im Data Lake in zwei Layern Bronze und Silber abgelegt.
  * Nach 12 Monaten liegen somit 2 (Dateien) * 24 (Stunden) * 365 (Tage) * 250 MB = 4.380.000 MB = 4,3 TB an Daten.
  * Die Datei muss pro Layer mindestens einmal geschrieben und einmal gelesen werden.
  * Somit ergeben sich 1 (Datei) * 2 (Layer) * 24 (Stunden) * 30 (Tage) = 1.440 Schreib- und Leseoperation pro Monat.
* Die Daten werden mittels Data Flows transformiert, die Orchestierung erfolgt mit Pipelines innerhalb der Data Factory.
  * Es werden zwei Pipelines mit jeweils 2 Task für das Verschieben und verarbeiten aufgebaut.
  * Daraus ergeben sich 1 (Datei) * 2 (Pipelines) * 2 (Tasks) * 24 (Stunden) * 30 (Tage) = 2.880 Taskausführungen pro Monat.
  * Für die Data Flows wird ein Cluster mit 8 Knoten genutzt.
  * Die Verarbeitung einer Datei pro Pipeline dauert 10 Minuten.
  * Daraus ergeben sich 1 (Datei) * 2 (Pipelines) * 10 (Minuten) * 24 (Stunden) * 30 (Tage) = 14.400 Minuten Ausführungszeit pro Monat.
* Die Azure SQL Datenbank fungiert als Service Layer für das Reporting. Dafür werden nur die aktuellen Daten benötigt. Monatlich wächst das Datenvolumen um 25 MB also 10% des initialen Datenvolumens.
  * Damit liegen nach 12 Monaten 250 MB (initial) + 12 * 25 MB = 550 MB in der Azure SQL Datenbank.
* Für Analysezwecke wird der dedizierte SQL Pool der Azure Synapse genutzt, dieser steht täglich von Mo - Fr 10 Stunden zur Verfügung. Es sind zunächst 4 Compute Nodes vorgesehen, was einer SKU von DW2000c entspricht.
  * Damit ergibt sich eine monatliche Laufzeit von 10 (Stunden) * 20 (Tagen) = 200 Stunden.


## Services

| Module | Service | SKU | Kosten (in Euro) | Beschreibung |
| --- | --- | --- | ---: | --- |
| Hub | Virtual Network | - | 4,00 | Peering mit 100 GB Datentransfer pro Monat |
| Hub | VPN Gateway | VpnGw1 | 138,73 | 730 Gatewaystunden pro Monat |
| Hub | Azure DNS | DNS | 9,90 | 19 DNS-Zonen mit 1 Millionen Abfragen pro Monat |
| Hub | Azure DNS | DNS Private Resolver | 180,05 | 1 eingehnder Endpunkt |
| Spoke Base | Virtual Network | - | 4,00 | Peering mit 100 GB Datentransfer pro Monat |
| Spoke Base | Azure Private Link | Private Endpoints | 86,20 | 9 Private Endpunkte mit 1 TB Datentransfer ein- und ausgehend pro Monat |
| Spoke Base | Key Vault | - | 0,30 | 100.000 Zugriffe pro Monat |
| Spoke Base | Automation | - | 7,66 | 60 Stunden pro Monat |
| Spoke Base | Azure Monitor | - | 100,78 | 1 GB Daten für Basisprotokoll, mit 1.000 Abfragen, 1 GB für Log Analytics, keine Warnungsregeln und keine Benachrichtigungen, Datenaufbewahrung 1 Monat |
| Spoke Base | Storage Account Logging | Block Blob Storage, Standard | 3,97 | 2 GB Daten pro Monat, 30.000 Vorgänge (alle) pro Monat |
| Spoke Storage | Storage Account | Data Lake Gen2 | 85,87 | siehe [Datenintegration](#datenintegration) |
| Spoke Storage | Azure SQL Datenbank | vCore, Standard (Gen5) | 488,38 | Standardbackup, kein PTR, siehe [Datenintegration](#datenintegration) |
| Spoke Integration | Azure Data Factory | - | 817,56 | siehe [Datenintegration](#datenintegration) |
| Spoke Analytics | Azure Synapse Analytics | DW2000c | 6.475,96 | siehe [Datenintegration](#datenintegration) |
| __Total__ | | | __8.432,03__ |  |

---
&#129044; [Terraform Spoke Module Synapse](12_Terraform_Spoke_Module_Synapse.md) &ensp;|&ensp; &#129045; [Inhaltsverzeichnis](00_Inhaltsverzeichnis.md) &ensp;|&ensp; [...](14_....md) &#129046;
