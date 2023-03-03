# Terraform Module Hub

[[_TOC_]]

Das Terraform module `adp_blueprint_hub` kann als Template für den Aufbau eines Hubs für die Azure Data Platform genutzt werden.

Unter Nutzung des Azure VPN Clients und des Azure DNS Private Resolvers kann der Zugriff auf die Services im Spoke komplett über eine VPN-Anbindung, die im Hub terminiert, erfolgen.

> Prinzipiell lässt sich die Data Platform auch ohne Hub bereitstellen. Eine höhere Sicherheit und Flexibilität lässt sich durch den Hub & Spoke Ansatz etablieren.

## Deployment-Prozess

Die Bereitstellung der Umgebung erfolgt derzeit in mehreren Schritten.

1. Aufbau des Hubs ohne Peering zum Spoke.
2. Bei Bedarf Installation des Azure VPN Clients und des Azure DNS Private Resolvers.
3. Aufbau des Spokes Basis Moduls mit Peering zum Hub.
4. Peering des Hubs zum Spoke.
5. Aufbau des Spoke Storage Moduls und Spoke Datenbank Moduls.
6. Aufbau des Spoke Integration Moduls und des Spoke Synapse Moduls.

> Der Rückbau der Resourcen erfolgt in umgekehrter Reihenfolge.

## Skripte

__./certificates/P2SRootCert.cer__

Rootzertifikate für den P2S VPN.

__./environments/cus-hub-blp.tfvars__

Initialisierung der Terraform-Variablen.

__000_init.tf__

Definition der benötigten Terraform Variablen.

__001_locals.tf__

Lokale Variable für das Module.

__002_data.tf__

Azure Resourcen, die für das weitere Deployment genutzt werden, z.B. Client (Service Principal) und Subscription.

__005_resource_group.tf__

Aufbau der Resourcengruppe für das VNET.

__010_virtual_network.tf__

Aufbau des VNETs.

__020_vpn.tf__

Aufbau des VPN. Ob der VPN aufgebaut wird, lässt sich durch die Variable vpn_gateway_enabled steuern.

__030_private_dns_zone.tf__

Aufbau der privaten DNS-Zonen und der virtuellen Links zum VNET.

__040_dns_private_resolver.tf__

Aufbau des Azure DNS Private Resolver.

__900_output.tf__

Ausgabe der IDs der privaten DNS-Zonen.


## Variablen

__adp_vnet_id__

ID des VNETs des Spokes der Azure Data Platform.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert:
```hcl
adp_vnet_id = null
```

Beispiel:
```hcl
adp_vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/cus-adp-blp-rg-net/providers/Microsoft.Network/virtualNetworks/cus-adp-blp-vnet"
```

__client_ips__

Liste von Client-IPs für die Firewall-Regeln hinterlegt werden.

Typ:
```hcl
list(object({
    name             = string
    cidr             = string
    start_ip_address = string
    end_ip_address   = string
}))
```

Sensitiv: nein

Standardwert:
```hcl
client_ips = null
```

Beispiel:
```hcl
client_ips = [
  {
    name             = "ClientIP01",
    cidr             = "20.79.204.165/32"
    start_ip_address = "20.79.204.165"
    end_ip_address   = "20.79.204.165"
  },
]
```

__client_secret__

Passwort des Service Principals für das Deployment. Initialisierung erfolgt ausschließlich über eine Umgebungsvariable.

Typ: 
```hcl
string
```

Sensitiv: ja

Standardwert: -

Beispiel (Umgebungsvariable):
```ps
$ENV:TF_VAR_client_secret="0000000000000000000000000000000000"
```

__dns_private_resolver_enabled__

DNS Private Resolver soll aufgebaut werden.

Typ:
```hcl
bool
```

Sensitiv: nein

Standardwert:
```hcl
dns_private_resolver_enabled = false
```

__location__

Azure Region, in der die Umgebung aufgebaut wird.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert:
```hcl
location = westeurope
```

__on_premises_networks__

Liste von Arvato Systems on-premises Netzwerken, für die die Firewall-Regeln etabliert werden sollen.

Typ:
```hcl
list(object({
  name             = string
  cidr             = string
  start_ip_address = string
  end_ip_address   = string
})
```

Sensitiv: nein

Standardwert: 
```hcl
on_premises_networks = null
```

Beispiel: 
```hcl
on_premises_networks = [
  {
    name             = "AllowFromOnPremises1"
    cidr             = "84.17.160.0/19"
    start_ip_address = "84.17.160.0"
    end_ip_address   = "84.17.191.255"
  },
  {
    name             = "AllowFromOnPremises2"
    cidr             = "109.235.136.0/21"
    start_ip_address = "109.235.136.0"
    end_ip_address   = "109.235.143.255"
  },
  {
    name             = "AllowFromOnPremises3"
    cidr             = "145.228.0.0/16"
    start_ip_address = "145.228.0.0"
    end_ip_address   = "145.228.255.255"
  }
]
```

__private_dns_zones__

Typ:
```hcl
map(string)
```

Sensitiv: nein

Standardwert:
```hcl
private_dns_zones = {
  dns_zone_adf                       = "privatelink.adf.azure.com"
  dns_zone_agentsvc_azure_automation = "privatelink.agentsvc.azure-automation.net"
  dns_zone_azure_automation          = "privatelink.azure-automation.net"
  dns_zone_azure_devices             = "privatelink.azure-devices.net"
  dns_zone_azuresynapse              = "privatelink.azuresynapse.net"
  dns_zone_blob                      = "privatelink.blob.core.windows.net"
  dns_zone_database                  = "privatelink.database.windows.net"
  dns_zone_datafactory               = "privatelink.datafactory.azure.net"
  dns_zone_dev_azuresynapse          = "privatelink.dev.azuresynapse.net"
  dns_zone_dfs                       = "privatelink.dfs.core.windows.net"
  dns_zone_file                      = "privatelink.file.core.windows.net"
  dns_zone_monitor                   = "privatelink.monitor.azure.com"
  dns_zone_oms_opinsights            = "privatelink.oms.opinsights.azure.com"
  dns_zone_ods_opinsights            = "privatelink.ods.opinsights.azure.com"
  dns_zone_queue                     = "privatelink.queue.core.windows.net"
  dns_zone_servicebus                = "privatelink.servicebus.windows.net"
  dns_zone_sql                       = "privatelink.sql.azuresynapse.net"
  dns_zone_table                     = "privatelink.table.core.windows.net"
  dns_zone_vaultcore                 = "privatelink.vaultcore.azure.net"
}
```

__project__

Projekt-Details, z.B. Kundenname, Umgebung, etc.

Typ:
```hcl
object({
  customer          = string
  name              = string
  environment       = string
  environment_short = string
})
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
project = {
  customer          = "cus"
  name              = "hub"
  environment       = "blp"
  environment_short = "b"
}
```

__tags__

Standard-Tags für die Resourcengruppen.

Typ:
```hcl
object({
  CreatedBy   = string
  Contact     = string
  Customer    = string
  Environment = string
  Project     = string
})
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
tags = {
  CreatedBy   = "<Name des Service Principals>"
  Contact     = "<name>@<domain>"
  Customer    = "Azure Data Platform Blueprint"
  Environment = "Blueprint"
  Project     = "Azure Data Platform Blueprint"
}
```

__virtual_network__

VNET-Details, Adressbereich, Subnetze, etc.

Typ:
```hcl
object({
  address_space = string

  subnets = map(object({
    name                = string
    address_space       = string
    client_address_pool = string
  }))
})
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
virtual_network = {
  address_space = "192.168.0.0/24"
  
  subnets = {
    gateway = {
      name                = "GatewaySubnet"
      address_space       = "192.168.0.0/27"
      client_address_pool = "192.168.255.0/27"
    },
    bastion = {
      name                = "AzureBastionSubnet"
      address_space       = "192.168.0.32/27"
      client_address_pool = null
    },
    dnspr_inbound = {
      name          = "DNSPrivateResolverInbound"
      address_space = "192.168.0.64/28"
      client_address_pool = null
    },
    dnspr_outbound = {
      name                = "DNSPrivateResolverOutbound"
      address_space       = "192.168.0.80/28"
      client_address_pool = null
    },
  }
}
```

__vpn_custom_route__

Liste von Azure Endpunkten.

Typ:
```hcl
list(string)
```

Sensitiv: nein

Standardwert:
```hcl
vpn_custom_route = null
```

Beispiel:
```hcl
# Sql.WestEurope, AzureSQL
vpn_custom_route = [
  "40.68.37.158/32", "104.40.168.105/32", "52.236.184.163/32", "104.40.169.32/29", "13.69.112.168/29", "52.236.184.32/29"
]
```

__vpn_gateway_enabled__

VPN Gateway soll aufgebaut werden.

Typ:
```hcl
bool
```

Sensitiv: nein

Standardwert:
```hcl
vpn_gateway_enabled = false
```

## Lokale Variablen

Die lokalen Variablen werden alle in der Datei `002_locals.tf` definiert.

__is_windows__

Bestimmung des OS, von dem aus der Aufbau der Azure Resourcen erfolgt.

Typ:
```hcl
string
```

Wert:
```hcl
is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
```


## Azure DNS Private Resolver

Zum Aufbau des Azure DNS Private Resolvers können auch nachfolgende [PowerShell Cmdlets](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-get-started-powershell) genutzt werden.

Beispiel:
```ps
Connect-AzAccount
New-AzDnsResolver -Name cus-hub-blp-dnspr -ResourceGroupName cus-hub-blp-rg-net -Location westeurope -VirtualNetworkId /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/cus-hub-blp-rg-net/providers/Microsoft.Network/virtualNetworks/cus-hub-blp-vnet
$ipConfig = New-AzDnsResolverIPConfigurationObject -PrivateIPAllocationMethod Dynamic -SubnetId /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/cus-hub-blp-rg-net/providers/Microsoft.Network/virtualNetworks/cus-hub-blp-vnet/subnets/DNSPrivateResolverInbound
New-AzDnsResolverInboundEndpoint -DnsResolverName cus-hub-blp-dnspr -Name cus-hub-blp-dnspr-inbound-ep -ResourceGroupName cus-hub-blp-rg-net -Location westeurope -IpConfiguration $ipConfig
Disconnect-AzAccount

Connect-AzAccount
Remove-AzDnsResolverInboundEndpoint -DnsResolverName cus-hub-blp-dnspr -Name cus-hub-blp-dnspr-inbound-ep -ResourceGroupName cus-hub-blp-rg-net
Remove-AzDnsResolver -Name cus-hub-blp-dnspr -ResourceGroupName cus-hub-blp-rg-net
Disconnect-AzAccount
```

## Azure VPN Client Konfiguration

Nach dem Aufbau des VPN Gateways muss die Konfiguration aus dem Azure Portal heruntergeladen werden. Bevor die Konfiguration in den Azure VPN Client hinzugefügt werden kann, muss in der `azurevpnconfig.xml` der Abschnitt für `<clientconfig i:nil="true" />` noch angepasst werden.


```xml
<clientconfig>
  <dnsservers>
    <dnsserver>"IP Adresse des Azure DNS Private Resolver Inbound Endpoints"</dnsserver>
  </dnsservers>
  <dnssuffixes>
    <dnssuffix>.adf.azure.com</dnssuffix>
    <dnssuffix>.agentsvc.azure-automation.net</dnssuffix>
    <dnssuffix>.azure-automation.net</dnssuffix>
    <dnssuffix>.azure-devices.net</dnssuffix>
    <!-- Erfordert den Aufbau eines Synapse Private Link Hubs -->
    <!--<dnssuffix>.azuresynapse.net</dnssuffix>-->
    <dnssuffix>.blob.core.windows.net</dnssuffix>
    <dnssuffix>.database.windows.net</dnssuffix>
    <dnssuffix>.datafactory.azure.net</dnssuffix>
    <dnssuffix>.dev.azuresynapse.net</dnssuffix>
    <dnssuffix>.dfs.core.windows.net</dnssuffix>
    <dnssuffix>.file.core.windows.net</dnssuffix>
    <dnssuffix>.monitor.azure.com</dnssuffix>
    <dnssuffix>.oms.opinsights.azure.com</dnssuffix>
    <dnssuffix>.ods.opinsights.azure.com</dnssuffix>
    <dnssuffix>.queue.core.windows.net</dnssuffix>
    <dnssuffix>.servicebus.windows.net</dnssuffix>
    <dnssuffix>.sql.azuresynapse.net</dnssuffix>
    <dnssuffix>.table.core.windows.net</dnssuffix>
    <dnssuffix>.vault.azure.net</dnssuffix>
    <dnssuffix>.vaultcore.azure.net</dnssuffix>
    </dnssuffixes>
</clientconfig>
```

---
&#129044; [Azure Data Platform Architektur](04_Azure_Data_Platform_Architektur.md) &ensp;|&ensp; &#129045; [Inhaltsverzeichnis](00_Inhaltsverzeichnis.md) &ensp;|&ensp; [Terraform Spoke](06_Terraform_Spoke.md) &#129046;
