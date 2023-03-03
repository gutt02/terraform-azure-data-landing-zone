# Terraform Spoke Modul Base

[[_TOC_]]

Aufbau von allgemeine Services, Resourcengruppen, VNET, Logging, Key Vault und Azure Automation Account.

## Skripte

__000_init.tf__

Definition der benötigten Terraform Variablen.

__001_data.tf__

Azure Resourcen, die für das weitere Deployment genutzt werden, z.B. Client (Service Principal) und Subscription.

__002_locals.tf__

Weitere lokale Variablen, die nicht im Root-Verzeichnis definiert werden.

__005_resource_group_base.tf__

Aufbau der definierten Resourcengruppen.

__010_virtual_network_base.tf__

Aufbau des Spoke VNETs, der Subnetze und des Peerings zum Hub.

__010_virtual_network_security.tf__

Aufbau der Network Security Groups und deren Zuordnungen zu den jeweiligen Subnetzen.

__050_monitor_base.tf__

Aufbau des Application Insights, des Log Analytics Workspace, des Log Storage Acounts. Aufbau zusätzlicher Resourcen bei der Aktivierung der privaten Endpunkte.

__050_monitor_private_endpoint.tf__

Aufbau der privaten Endpunkte für das Application Insights und den Log Storage Account.

__060_key_vault_base.tf__

Aufbau des Key Vaults.

__060_key_vault_private_endpoint.tf__

Aufbau des privaten Endpunkts für den Key Vault.

__070_automation_base.tf__

Aufbau des Automation Accounts und Berechtigung als Reader auf der Subscription.

__070_automation_private_endpoint.tf__

Aufbau des privaten Endpunkts für den Automation Account.

__900_role_assignment.tf__

RBAC Assignment für die Resourcengruppen, Log Analytics, Key Vault und den Log Storage Account.

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

__hub_vnet_id__

ID des VNETs im Hub für das Peering. Bei null wird nicht gepeert.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert: -

Beispiel: 
```hcl
hub_vnet_id = /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/cus-hub-blp-rg-net/providers/Microsoft.Network/virtualNetworks/cus-hub-blp-vnet
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

__aacc__

Konfiguration für den Automation Account.

Typ:
```hcl
object({
  sku_name   = string
  is_enabled = bool
})
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
aacc = {
  sku_name   = "Basic"
  is_enabled = true
}
```

__app_insights__

Konfiguration für Application Insights.

Typ: 
```hcl
object({
  application_type = string
  is_enabled       = bool
})
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
app_insights = {
  application_type = "other"
  is_enabled       = true
}
```

__key_vault__

Konfiguration für den Key Vault.

Typ:
```hcl
object({
  integration_runtime         = string
  is_enabled                  = bool
  linked_service_enabled      = bool
  sku_name                    = string
  synapse_integration_runtime = string
})
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
key_vault = {
  integration_runtime         = "AzureIntegrationRuntime01"
  is_enabled                  = true
  linked_service_enabled      = true
  sku_name                    = "standard"
  synapse_integration_runtime = "AzureIntegrationRuntime01"
}
```

__log_analytics__

Konfiguration für den Log Analytics Workspace.

Typ:
```hcl
object({
  is_enabled = bool
  sku        = string
})
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
log_analytics = {
  is_enabled = true
  sku        = "PerGB2018"
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
  rg_evhub = {
    name       = "rg-evhub"
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

__strg_log__

Konfiguration für den Azure Blob Storage für das Logging.

Typ:
```hcl
object({
  account_kind             = string
  account_tier             = string
  account_replication_type = string
  is_enabled               = bool
  is_hns_enabled           = bool
  })
```

Sensitiv: nein

Standardwert: -

Beispiel:
```hcl
strg_log = {
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_enabled               = true
  is_hns_enabled           = false
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

__role_assignments_resource_group___

Zuordnung der RBAC-Berechtigungen der Azure Active Directory Sicherheitsgruppen zu den Resourcengruppen.

Typ:
```hcl
map(object({
  key                = string
  security_group_key = string
  role_key           = string
  resource_key       = string
  name               = string
  object_id          = string
  role               = string
  scope              = string
}))
```

Wert:
```hcl
role_assignments_resource_group = flatten([
  for security_group_key, security_group in var.security_groups : [
    for role_key, role in security_group.role_assignments.resource_group : [
      for resource_key, resource in azurerm_resource_group.rg : {
        key                = "${lower(replace(security_group.name, " ", "_"))}.${lower(replace(role, " ", "_"))}.${lower(replace(resource.name, " ", "_"))}"
        security_group_key = security_group_key
        role_key           = role_key
        resource_key       = resource_key
        name               = security_group.name
        object_id          = security_group.object_id
        role               = role
        scope              = resource.id
      } if var.module_enabled && try(resource.tags.role_assignment_enabled, false)
    ]
  ]
])
```

__role_assignments_log_analytics_la___

Zuordnung der RBAC-Berechtigungen der Azure Active Directory Sicherheitsgruppen zum Log Analytics Workspace.

Typ:
```hcl
map(object({
  key                = string
  security_group_key = string
  role_key           = string
  resource_key       = string
  name               = string
  object_id          = string
  role               = string
  scope              = string
}))
```

Wert:
```hcl
role_assignments_log_analytics_la = flatten([
  for security_group_key, security_group in var.security_groups : [
    for role_key, role in security_group.role_assignments.log_analytics : {
      key                = "${lower(replace(security_group.name, " ", "_"))}.${lower(replace(role, " ", "_"))}.${lower(replace(azurerm_log_analytics_workspace.la[0].name, " ", "_"))}"
      security_group_key = security_group_key
      role_key           = role_key
      resource_key       = azurerm_log_analytics_workspace.la[0].name
      name               = security_group.name
      object_id          = security_group.object_id
      role               = role
      scope              = azurerm_log_analytics_workspace.la[0].id
    } if var.module_enabled && try(azurerm_log_analytics_workspace.la[0].tags.role_assignment_enabled, false)
  ]
])
```

__role_assignments_key_vault_kv___

Zuordnung der RBAC-Berechtigungen der Azure Active Directory Sicherheitsgruppen zum Key Vault.

Typ:
```hcl
map(object({
  key                = string
  security_group_key = string
  role_key           = string
  resource_key       = string
  name               = string
  object_id          = string
  role               = string
  scope              = string
}))
```

Wert:
```hcl
role_assignments_key_vault_kv = flatten([
  for security_group_key, security_group in var.security_groups : [
    for role_key, role in security_group.role_assignments.key_vault : {
      key                = "${lower(replace(security_group.name, " ", "_"))}.${lower(replace(role, " ", "_"))}.${lower(replace(azurerm_key_vault.key_vault[0].name, " ", "_"))}"
      security_group_key = security_group_key
      role_key           = role_key
      resource_key       = azurerm_key_vault.key_vault[0].name
      name               = security_group.name
      object_id          = security_group.object_id
      role               = role
      scope              = azurerm_key_vault.key_vault[0].id
    } if var.module_enabled && try(azurerm_key_vault.key_vault[0].tags.role_assignment_enabled, false)
  ]
])
```

__role_assignments_storage_account___

Zuordnung der RBAC-Berechtigungen der Azure Active Directory Sicherheitsgruppen zum Log Storage Account.

Typ:
```hcl
map(object({
  key                = string
  security_group_key = string
  role_key           = string
  resource_key       = string
  name               = string
  object_id          = string
  role               = string
  scope              = string
}))
```

Wert:
```hcl
role_assignments_storage_account = flatten([
  for security_group_key, security_group in var.security_groups : [
    for role_key, role in security_group.role_assignments.storage_account : {
      key                = "${lower(replace(security_group.name, " ", "_"))}.${lower(replace(role, " ", "_"))}.${lower(replace(azurerm_storage_account.strglog[0].name, " ", "_"))}"
      security_group_key = security_group_key
      role_key           = role_key
      resource_key       = azurerm_storage_account.strglog[0].name
      name               = security_group.name
      object_id          = security_group.object_id
      role               = role
      scope              = azurerm_storage_account.strglog[0].id
    } if var.module_enabled && try(azurerm_storage_account.strglog[0].tags.role_assignment_enabled, false)
  ]
])
```

---
&#129044; [Terraform Spoke](06_Terraform_Spoke.md) &ensp;|&ensp; &#129045; [Inhaltsverzeichnis](00_Inhaltsverzeichnis.md) &ensp;|&ensp; [Terraform Spoke Module Storage](08_Terraform_Spoke_Module_Storage.md) &#129046;