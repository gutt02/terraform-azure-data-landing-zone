# Terraform Spoke Modul Streaming

[[_TOC_]]

Aufbau eines Eventhub Namespace und Eventhubs.

## Skripte

__000_init.tf__

Definition der benötigten Terraform Variablen.

__001_data.tf__

Azure Resourcen, die für das weitere Deployment genutzt werden, z.B. Client (Service Principal), Subscription, Log Storage Account, Subnetz für private Endpunkte, Blob Storage Accounts, etc.

__002_locals.tf__

Weitere lokale Variablen, die nicht im Root-Verzeichnis definiert werden.

__100_eventhub_base.tf__

Anlegen der Event Hubs im Eventhub Namesapce.

__100_eventhub_namespace_base.tf__

Aufbau des Eventhub Namespace.

__100_eventhub_namespace_private_endpoint.tf__

Erstellen des privaten Endpunkts für den Eventhub Namespace.

__100_iothub_base.tf__

Aufbau des Iothubs.

__100_iothub_endpoints.tf__

Aufbau der Endpunkte für die Routen des Iothubs, aktuell nur für einen Storage Account.

__100_iothub_private_endpoint.tf__

Aufbau des privaten Endpunkts für den Iothub.

__100_iothub_routes.tf__

Aufbau der Routen für die Nachrichtenweiterleitung, aktuell nur für einen Storage Account.

__900_role_assignment.tf__

Berechtigungen des Eventhub Namespace und Iothubs auf dem Storage Account.

__999_output.tf__

Definition einer Abhängigkeit auf einige Resourcen für die nächsten Module.

## Projektspezifische Variablen

__client_ips__

Liste von Client-IPs für die Firewall-Regeln hinterlegt werden.

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

Standardwert: -

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

__environment_is_private__

Umgebung ist privat, d.h., der Zugriff ist nur über private Endpunkte möglich.

Typ: 
```hcl
bool
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
environment_is_private = false
```

__hub_subnet_gateway_id__

ID des Gateways im Hub.

Typ: 
```hcl
string
```

Sensitiv: nein

Standardwert: -

Beispiel: 
```hcl
hub_subnet_gateway_id = /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/cus-hub-blp-rg-net/providers/Microsoft.Network/virtualNetworks/cus-hub-blp-vnet/subnets/GatewaySubnet
```

__local_deployment_enabled__

Die Bereitstellung der Azure Resourcen erfolgt vom lokalen Client.

Typ:
```hcl
bool
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
local_deployment_enabled = true
```

__location__

Azure Region, in der die Umgebung aufgebaut wird.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert: -

Beispiel:
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

Standardwert: -

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

__private_dns_zone_id__

Private DNS Zone-Id, die im Hub erstellt wurde.

Typ:
```hcl
string
```

Standardwert: -

Beispiel:
```hcl
private_dns_zone_id = "/subscriptions/00000000-0000-0000-000000000000/resourceGroups/cus-hub-blp-rg-net/providers/Microsoft.Network/privateDnsZones"
```

__private_dns_zones__

Liste der IDs der privaten DNS-Zonen.

Typ:
```hcl
map(string)
```

Sensitiv: nein

Standardwert: -

Beispiel:
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
  name              = "adp"
  environment       = "blp"
  environment_short = "b"
}
```

__role_assignment_enabled__

RBAC Assignment ist aktiviert.

Typ:
```hcl
bool
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
role_assignment_enabled = true
```

__security_groups__

RBAC Definitionen für die Security Groups.

Typ:
```hcl
list(object({
  name      = string
  object_id = string

  role_assignments = object({
    data_factory      = list(string)
    key_vault         = list(string)
    log_analytics     = list(string)
    mssql_server      = list(string)
    resource_group    = list(string)
    storage_account   = list(string)
    synapse_workspace = list(string)
  })
}))
```

Sensitiv: nein

Standardwert: -

Beispiel: 
```hcl
security_groups = [
  {
    # Data and Platform Engineer
    name      = "<Full name of the AAD security group>"
    object_id = "00000000-0000-0000-0000-000000000000"
    role_assignments = {
      "data_factory"   = ["Data Factory Contributor"]
      "key_vault"      = ["Key Vault Administrator"]
      "log_analytics"  = ["Log Analytics Contributor"]
      "mssql_server"   = []
      "resource_group" = ["Contributor"]
      "storage_account" = [
        "Storage Account Contributor",
        "Storage Blob Data Contributor",
        "Storage File Data SMB Share Contributor",
        "Storage Queue Data Contributor",
        "Storage Table Data Contributor"
      ]
      "synapse_workspace" = ["Apache Spark Administrator", "Synapse Administrator", "Synapse Contributor", "Synapse SQL Administrator"]
    }
  },
  {
    # Data Analyst
    name      = "<Full name of the AAD security group>"
    object_id = "00000000-0000-0000-0000-000000000000"
    role_assignments = {
      "data_factory"   = []
      "key_vault"      = ["Key Vault Reader"]
      "log_analytics"  = ["Log Analytics Reader"]
      "mssql_server"   = []
      "resource_group" = ["Reader"]
      "storage_account" = [
        "Storage Blob Data Reader",
        "Storage File Data SMB Share Reader",
        "Storage Queue Data Reader",
        "Storage Table Data Reader"
      ]
      "synapse_workspace" = ["Synapse Artifact Publisher", "Synapse Artifact User"]
    }
  },
  {
    # Data Scientist
    name      = "<Full name of the AAD security group>"
    object_id = "00000000-0000-0000-0000-000000000000"
    role_assignments = {
      "data_factory"   = []
      "key_vault"      = ["Key Vault Reader"]
      "log_analytics"  = ["Log Analytics Reader"]
      "mssql_server"   = []
      "resource_group" = ["Reader"]
      "storage_account" = [
        "Storage Blob Data Reader",
        "Storage File Data SMB Share Reader",
        "Storage Queue Data Reader",
        "Storage Table Data Reader"
      ]
      "synapse_workspace" = ["Synapse Artifact Publisher", "Synapse Artifact User"]
    }
  },
  {
    # Data Steward
    name      = "<Full name of the AAD security group>"
    object_id = "00000000-0000-0000-0000-000000000000"
    role_assignments = {
      "data_factory" = ["Data Factory Contributor"]
      "key_vault" = [
        "Key Vault Certificates Officer",
        "Key Vault Crypto Officer",
        "Key Vault Secrets Officer"
      ]
      "log_analytics"     = ["Log Analytics Reader"]
      "mssql_server"      = []
      "resource_group"    = ["Reader"]
      "storage_account"   = ["Storage Blob Data Owner"]
      "synapse_workspace" = ["Synapse Artifact Publisher", "Synapse Artifact User"]
    }
  },
]
```

__virtual_network__

VNET-Details, Adressbereich, Subnetze, etc.

Typ:
```hcl
object({
  address_space = string

  subnets = map(object({
    name          = string
    address_space = string
  }))
})
```

Sensitiv: nein

Standardwert: -

Beispiel: 
```hcl
virtual_network = {
  address_space = "x.x.x.x/25"
  subnets = {
    shared_services = {
      name          = "shared-services"
      address_space = "x.x.x.x/28"
    },
    virtual_machines = {
      name          = "virtual-machines"
      address_space = "x.x.x.x/28"
    },
    prep = {
      name          = "prep"
      address_space = "x.x.x.x/26"
    }
  }
}
```

## Modulspezifische Variablen

__eventhub_namespace__

Konfiguration des Eventhub Namespace.

Typ:
```hcl
object({
  is_enabled = bool
  suffix     = string
  sku        = string
  capacity   = number

  eventhubs = list(object({
    bbs                             = string
    capture_description_enabled     = bool
    capture_description_encoding    = string
    destination_archive_name_format = string
    destination_blob_container_name = string
    is_enabled                      = bool
    name                            = string
    message_retention               = number
    partition_count                 = number
  }))
})
```

Sensitiv: nein

Standardwert: -

Beispiel: 
```hcl
eventhub_namespace = {
  is_enabled = true
  suffix     = "evhub-ns-01"
  sku        = "Standard"
  capacity   = 2

  eventhubs = [
    {
      bbs                             = "bbs01"
      capture_description_enabled     = true
      capture_description_encoding    = "Avro"
      destination_archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      destination_blob_container_name = "evhub01"
      is_enabled                      = true
      name                            = "evhub01"
      message_retention               = 1
      partition_count                 = 2
    },
    {
      bbs                             = "bbs01"
      capture_description_enabled     = true
      capture_description_encoding    = "Avro"
      destination_archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      destination_blob_container_name = "evhub02"
      is_enabled                      = true
      name                            = "evhub02"
      message_retention               = 1
      partition_count                 = 2
    }
  ]
}
```

__iothub__

Konfiguration des Iothubs.

Typ:
```hcl
type = object({
  is_enabled   = bool
  suffix       = string
  sku_name     = string
  sku_capacity = string

  endpoints = list(object({
    bbs              = string
    is_enabled       = bool
    name             = string
    container_name   = string
    encoding         = string
    file_name_format = string
  }))

  routes = list(object({
    condition     = string
    endpoint_name = string
    enabled       = bool
    is_enabled    = bool
    name          = string
    source        = string
  }))
})
```

Sensitiv: nein

Standardwert: -

Beispiel: 
```hcl
iothub = {
  is_enabled   = true
  suffix       = "iothub-01"
  sku_name     = "F1"
  sku_capacity = "1"

  endpoints = [
    {
      bbs              = "bbs01"
      is_enabled       = true
      name             = "iothub01"
      container_name   = "iothub01"
      encoding         = "Avro"
      file_name_format = "{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}"
    }
  ]

  routes = [
    {
      condition     = "true"
      endpoint_name = "iothub01"
      enabled       = true
      is_enabled    = true
      name          = "route01"
      source        = "DeviceMessages"
    }
  ]
}
```

__module_enabled__

Module ist aktiv.

Typ:
```hcl
bool
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
module_enabled = true
```

__resource_groups__

Liste der Resourcengruppen, die aufgebaut werden sollen.

Typ:
```hcl
map(object({
  name       = string
  is_enabled = bool
}))
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
resource_groups = {
  rg_adf = {
    name       = "rg-adf"
    is_enabled = true
  }
  rg_app = {
    name       = "rg-app"
    is_enabled = false
  }
  rg_automation = {
    name       = "rg-automation"
    is_enabled = true
  }
  rg_db = {
    name       = "rg-db"
    is_enabled = true
  }
  rg_kv = {
    name       = "rg-kv"
    is_enabled = true
  }
  rg_log = {
    name       = "rg-log"
    is_enabled = true
  }
  rg_lvm = {
    name       = "rg-lvm"
    is_enabled = false
  }
  rg_net = {
    name       = "rg-net"
    is_enabled = true
  }
  rg_stm = {
    name       = "rg-stm"
    is_enabled = true
  }
  rg_strg = {
    name       = "rg-strg"
    is_enabled = true
  }
  rg_synapse = {
    name       = "rg-synapse"
    is_enabled = true
  }
  rg_wvm = {
    name       = "rg-wvm"
    is_enabled = false
  }
}
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

__ip_rules__

Verknüfung der IPs aus den Client-IPs und den on-premises Netzwerken.

Typ:
```string```

Wert:
```hcl
ip_rules = var.environment_is_private ? var.local_deployment_enabled ? replace(join(", ", var.client_ips.*.cidr), "/32", "") : null : replace(join(",", concat(var.on_premises_networks.*.cidr, var.client_ips.*.cidr)), "/32", "")
```

__managed_private_endpoint_enabled__

Gemanagete private Endpunkte sind aktiviert.

Typ:
```hcl
bool
```

Wert:
```hcl
managed_private_endpoint_enabled = var.environment_is_private
```

__private_endpoint_enabled__

Private Endpunkte sind aktiviert.

Typ:
```hcl
bool
```

Wert:
```hcl
private_endpoint_enabled = var.environment_is_private
```

---
&#129044; [Terraform Spoke Module Data Factory](10_Terraform_Spoke_Module_Data_Factory.md) &ensp;|&ensp; &#129045; [Inhaltsverzeichnis](00_Inhaltsverzeichnis.md) &ensp;|&ensp; [Terraform Spoke Module Synapse](12_Terraform_Spoke_Module_Synapse.md) &#129046;
