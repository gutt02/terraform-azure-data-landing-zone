# Terraform Spoke Modul Data Factory

[[_TOC_]]

Aufbau einer Azure Data Factory mit Integration Runtime und Linked Services.

## Skripte

__000_init.tf__

Definition der benötigten Terraform Variablen.

__001_data.tf__

Azure Resourcen, die für das weitere Deployment genutzt werden, z.B. Client (Service Principal), Subscription, Log Storage Account, Subnetz für private Endpunkte, Azure Key Vault, Blob Storage Accounts, Azure Data Lake Storage Gen2, Azure SQL Server, etc.

__002_locals.tf__

Weitere lokale Variablen, die nicht im Root-Verzeichnis definiert werden, z.B. Zuordnung der RBAC Konfiguration für den Azure Data Factory auf Basis der Konfiguration im Root-Verzeichnis.

__100_data_factory_base.tf__

Aufbau der Azure Data Factory.

__100_data_factory_database_permission.tf__

Anlegen des Datenbank Users für die Managed Identity der Azure Data Factory. Anm.: Die Datenbanken müssen vom Deployment Client erreichbar sein und das Kommandozeilen-Tool `sqlcmd` muss installiert sein.

__100_data_factory_diagnostic.tf__

Aufbau der Diagnostics Settings für `ActivityRuns`, `PipelineRuns` und `TriggerRuns`.

__100_data_factory_integration_runtime.tf__

Aufbau der Azure Hosted Integration Runtime.

__100_data_factory_linked_service.tf__

Aufbau der konfigurierten Linked Services für den Blob Storage Account, Azure Data Lake Storage Gen2, Key Vault und Azure SQL Database.

__100_data_factory_managed_private_endpoint.tf__

Aufbau der Azure Data Factory managed privaten Endpunkte für den Blob Storage Account, den Azure Data Lake Storage Gen2, den Key Vault und die Azure SQL Datenbanken.

__100_data_factory_private_endpoint.tf__

Aufbau des privaten Endpunkts für die Azure Data Factory.

__900_role_assignment.tf__

Anlegen der Berechtigung auf dem Key Vault, den Storage Accounts und RBAC Assignment für die Azure Data Factory.

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

__data_factory__

Konfiguration der Azure Data Factory.

Typ:
```hcl
object({
  is_enabled = bool
  suffix     = string

  integration_runtimes = list(object({
    name             = string
    compute_type     = string
    core_count       = number
    time_to_live_min = number
  }))
})
```

Sensitiv: nein

Standardwert: -

Beispiel: 
```hcl
data_factory = {
  is_enabled = true
  suffix     = "adf-01"

  integration_runtimes = [
    {
      name             = "AzureIntegrationRuntime01"
      compute_type     = "General"
      core_count       = 8
      time_to_live_min = 15
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

__sql_aad_admin_login__

Azure Active Directory SQL Admin Login.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert: -

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_sql_aad_admin_login="<user>@<domain>"
```

__sql_aad_admin_password__

Azure Active Directory SQL Admin Passwort.

Typ:
```hcl
string
```

Sensitiv: ja

Standardwert: -

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_sql_aad_admin_password="00000000000000000000"
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

__mssql_database__

Zuordnung der Azure SQL Datenbanken zu den entsprechenden Azure SQL Datenbankservern.

Typ:
```hcl
map(object({
  key                = string
  mssql_server_key   = string
  mssql_database_key = string
  mssql_server       = string
  mssql_database     = string
}))
```

Wert:
```hcl
mssql_database = flatten([
  for mssql_server_key, mssql_server in data.azurerm_mssql_server.mssql_server : [
    for mssql_database_key, mssql_database in data.azurerm_mssql_database.mssql_database : {
      key                = "${lower(replace(mssql_server.name, " ", "_"))}.${lower(replace(mssql_database.name, " ", "_"))}"
      mssql_server_key   = mssql_server_key
      mssql_database_key = mssql_database_key
      mssql_server       = mssql_server
      mssql_database     = mssql_database
    } if var.module_enabled && var.data_factory.is_enabled && mssql_database.server_id == mssql_server.id
  ]
])
```

__role_assignments_data_factory__

Zuordnung der RBAC-Berechtigungen der Azure Active Directory Sicherheitsgruppen zur Azure Data Factory.

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
role_assignments_data_factory = flatten([
  for security_group_key, security_group in var.security_groups : [
    for role_key, role in security_group.role_assignments.data_factory : {
      key                = "${lower(replace(security_group.name, " ", "_"))}.${lower(replace(role, " ", "_"))}.${lower(replace(azurerm_data_factory.data_factory[0].name, " ", "_"))}"
      security_group_key = security_group_key
      role_key           = role_key
      resource_key       = azurerm_data_factory.data_factory[0].name
      name               = security_group.name
      object_id          = security_group.object_id
      role               = role
      scope              = azurerm_data_factory.data_factory[0].id
    } if var.module_enabled && try(azurerm_data_factory.data_factory[0].tags.role_assignment_enabled, false)
  ]
])
```

---
&#129044; [Terraform Spoke Module Database](09_Terraform_Spoke_Module_Database.md) &ensp;|&ensp; &#129045; [Inhaltsverzeichnis](00_Inhaltsverzeichnis.md) &ensp;|&ensp; [Terraform Spoke Module Streaming](11_Terraform_Spoke_Module_Streaming.md) &#129046;