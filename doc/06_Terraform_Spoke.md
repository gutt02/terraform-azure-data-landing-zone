# Terraform Modul Spoke

[[_TOC_]]

Im Spoke werden alle Azure Services für die Data Platform aufgebaut. Dabei kann über die an die Module übergebene Variable `module_enabled` gesteuert werden, ob das entsprechende Module aufgebaut werden soll. Bei den jeweiligen Services kann über das Attribute `is_enabled` konifiguriert werden, ob der jeweilige Service aufgebaut wird. 

## Skripte

__./environments/cus-adp-blp.tfvars__

Initialisierung der Terraform-Variablen.

__000_init.tf__

Definition der benötigten Terraform Variablen und Integration der Module.

__001_data.tf__

Azure Resourcen, die für das weitere Deployment genutzt werden, z.B. Client (Service Principal) und Subscription.

__002_locals.tf__

Lokale Variable für das Module.

__900_output.tf__

Derzeit werden keine Werte von aufgebauten Resourcen zurückgegeben.

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

__environment_is_private__

Umgebung ist privat, d.h., der Zugriff ist nur über private Endpunkte möglich.

Typ: 
```hcl
bool
```

Sensitiv: nein

Standardwert:
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

Standardwert: 
```hcl
hub_subnet_gateway_id = null
```

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

Standardwert:
```hcl
hub_vnet_id = null
```

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

Standardwert:
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

__private_dns_zone_id__

Private DNS Zone-Id, die im Hub erstellt wurde.

Typ:
```hcl
string
```

Standardwert:
```hcl
private_dns_zone_id = null
```

__private_dns_zones__

Liste der IDs der privaten DNS-Zonen.

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

Standardwert: 
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

Standardwert: 
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

Standardwert:
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

Standardwert:
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

Standardwert:
```hcl
log_analytics = {
  is_enabled = true
  sku        = "PerGB2018"
}
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

Standardwert:
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

Standardwert: 
```hcl
strg_log = {
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_enabled               = true
  is_hns_enabled           = false
}
```

__strg__

Konfiguration der Azure Storage Accounts.

Typ:
```hcl
type = list(object({
  account_kind                = string
  account_tier                = string
  account_replication_type    = string
  integration_runtime         = string
  is_enabled                  = bool
  is_hns_enabled              = bool
  linked_service_enabled      = bool
  suffix                      = string
  synapse_integration_runtime = string
  prep_blob_enabled           = bool
  prep_dfs_enabled            = bool
  prep_file_enabled           = bool
  prep_queue_enabled          = bool
  prep_table_enabled          = bool

  # Should be part of the application deployment
  containers = list(object({
    name        = string
    access_type = string
  }))
}))
```

Sensitiv: nein

Standardwert: 
```hcl
strg = null
```

Beispiel: 
```hcl
strg = [
  # Azure Blob Storage
  {
    account_kind                = "StorageV2"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    integration_runtime         = "AzureIntegrationRuntime01"
    is_enabled                  = true
    is_hns_enabled              = false
    linked_service_enabled      = true
    suffix                      = "bbs01"
    synapse_integration_runtime = "AzureIntegrationRuntime01"
    prep_blob_enabled           = true
    prep_dfs_enabled            = false
    prep_file_enabled           = true
    prep_queue_enabled          = true
    prep_table_enabled          = true

    # Should be part of the application deployment
    containers = [
      {
        name        = "hot"
        access_type = "private"
      },
      {
        name        = "cold"
        access_type = "private"
      },
      {
        name        = "archive"
        access_type = "private"
      }
    ]
  },
  # Azure Data Lake Storage Gen2
  {
    account_kind                = "StorageV2"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    integration_runtime         = "AzureIntegrationRuntime01"
    is_enabled                  = true
    is_hns_enabled              = true
    linked_service_enabled      = true
    suffix                      = "dfs01"
    synapse_integration_runtime = "AzureIntegrationRuntime01"
    prep_blob_enabled           = true
    prep_dfs_enabled            = true
    prep_file_enabled           = false
    prep_queue_enabled          = false
    prep_table_enabled          = false

    # Should be part of the application deployment
    containers = [
      {
        name        = "raw"
        access_type = "private"
      },
      {
        name        = "refined"
        access_type = "private"
      },
      {
        name        = "prod"
        access_type = "private"
      }
    ]
  }
]
```

__mssql_server__

Konfiguration des Azure SQL Datenbankservers.

Typ:
```hcl
list(object({
  # azuread_authentication_only   = bool
  azuread_authentication_only   = bool
  public_network_access_enabled = bool
  is_enabled                    = bool
  suffix                        = string
  version                       = string

  elastic_pool = object({
    is_enabled                         = bool
    license_type                       = string
    max_size_gb                        = number
    sku_name                           = string
    sku_tier                           = string
    sku_family                         = string
    sku_capacity                       = number
    per_database_settings_min_capacity = number
    per_database_settings_max_capacity = number
  })

  # Should be part of the application
  databases = list(object({
    name                        = string
    collation                   = string
    sku_name                    = string
    integration_runtime         = string
    linked_service_enabled      = bool
    synapse_integration_runtime = string
  }))
}))
```

Sensitiv: nein

Standardwert:
```hcl
mssql_server = null
```

Beispiel: 
```hcl
mssql_server = [
  {
    # azuread_authentication_only   = true
    azuread_authentication_only   = false
    public_network_access_enabled = true
    is_enabled                    = true
    suffix                        = "mssql-01"
    version                       = "12.0"

    elastic_pool = {
      is_enabled                         = true
      license_type                       = "LicenseIncluded"
      max_size_gb                        = 9.7656250
      sku_name                           = "BasicPool"
      sku_tier                           = "Basic"
      sku_family                         = null
      sku_capacity                       = 100
      per_database_settings_min_capacity = 0
      per_database_settings_max_capacity = 5
    }

    # Should be part of the application deployment
    databases = [
      {
        name                        = "DBSADPBLP01"
        collation                   = "Latin1_General_100_CI_AI_SC_UTF8"
        sku_name                    = "Basic"
        integration_runtime         = "AzureIntegrationRuntime01"
        linked_service_enabled      = true
        synapse_integration_runtime = "AzureIntegrationRuntime01"
      }
    ]
  }
]
```

__sql_aad_admin_login__

Azure Active Directory SQL Admin Login.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert:
```hcl
sql_aad_admin_login = null
```

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_sql_aad_admin_login="<user>@<domain>"
```

__sql_aad_admin_object_id__

Azure Active Directory SQL Admin Object Id.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert:
```hcl
sql_aad_admin_object_id = null
```

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_sql_aad_admin_object_id="00000000-0000-0000-0000-000000000000"
```

__sql_aad_admin_password__

Azure Active Directory SQL Admin Passwort.

Typ:
```hcl
string
```

Sensitiv: ja

Standardwert:
```hcl
sql_aad_admin_password = null
```

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_sql_aad_admin_password="00000000000000000000"
```

__sql_admin_login__

SQL Admin Login.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert:
```hcl
sql_admin_login = null
```

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_sql_admin_login="sqladmin"
```

__sql_admin_password__

SQL Admin Passwort.

Typ:
```hcl
string
```

Sensitiv: ja

Standardwert:
```hcl
sql_admin_password = null
```

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_sql_admin_password="00000000000000000000"
```

__data_factory__

Konfiguration der Azure Data Factory.

Typ:
```hcl
list(object({
  is_enabled = bool
  suffix     = string

  integration_runtimes = list(object({
    name             = string
    compute_type     = string
    core_count       = number
    time_to_live_min = number
  }))
}))
```

Sensitiv: nein

Standardwert:
```hcl
data_factory = null
```

Beispiel: 
```hcl
data_factory = [
  {
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
]
```

__streaming__

Konfiguration des Eventhub Namespace und des Iothubs.

Typ:
```hcl
type = list(object({
  eventhub_namespace = object({
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

  iothub = object({
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
}))
```

Sensitiv: nein

Standardwert:
```hcl
null
```

Beispiel:
```hcl
streaming = [
  {
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
  }
]
```

__synapse_aad_admin_login__

Azure Active Directory Azure Synapse Analytics Admininstrator Login.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert:
```hcl
synapse_aad_admin_login = null
```

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_synapse_aad_admin_login="<user>@<domain>"
```

__synapse_aad_admin_object_id__

Azure Active Directory Azure Synapse Analytics Analytics Admininstrator Object Id.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert:
```hcl
synapse_aad_admin_object_id = null
```

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_synapse_aad_admin_object_id="00000000-0000-0000-0000-000000000000"
```

__synapse_sql_aad_admin_login__

SQL Azure Active Directory Azure Synapse Analytics Admininstrator Login.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert:
```hcl
synapse_sql_aad_admin_login = null
```

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_synapse_sql_aad_admin_login="<user>@<domain>"
```

__synapse_sql_aad_admin_object_id__

SQL Azure Active Directory Azure Synapse Analytics Admininstrator Object Id.

Typ:
```hcl
string
```

Sensitiv: nein

Standardwert:
```hcl
synapse_sql_aad_admin_object_id = null
```

Beispiel (Umgebungsvariable): 
```ps
$ENV:TF_VAR_synapse_sql_aad_admin_object_id="00000000-0000-0000-0000-000000000000"
```
__synapse_workspace__

Konfiguration des Azure Synapse Analytics Workspace.

Typ:
```hcl
list(object({
  is_enabled = bool
  dfs        = string
  suffix     = string

  spark_pools = list(object({
    auto_pause_delay_in_minutes = number
    auto_scale_max_node_count   = number
    auto_scale_min_node_count   = number
    cache_size                  = number
    is_enabled                  = bool
    node_size                   = string
    node_size_family            = string
    suffix                      = string
    spark_version               = string
  }))

  sql_pools = list(object({
    auto_pause                  = string
    data_encrypted              = bool
    collation                   = string
    create_mode                 = string
    is_enabled                  = bool
    sku_name                    = string
    suffix                      = string
    synapse_integration_runtime = string
  }))

  integration_runtimes = list(object({
    name             = string
    compute_type     = string
    core_count       = number
    time_to_live_min = number
    is_enabled       = bool
  }))
}))
```

Sensitiv: nein

Standardwert:
```hcl
synapse_workspace = null
```

Beispiel: 
```hcl
synapse_workspace = [
  {
    is_enabled = true
    dfs        = "dfs01"
    suffix     = "synws-01"

  spark_pools = [
    {
      auto_pause_delay_in_minutes = 15
      auto_scale_max_node_count   = 10
      auto_scale_min_node_count   = 3
      cache_size                  = 100
      is_enabled                  = true
      node_size                   = "Small"
      node_size_family            = "MemoryOptimized"
      suffix                      = "asp01"
      spark_version               = "3.2"
    }
  ]

  sql_pools = [
      {
        auto_pause     = "enabled"
        data_encrypted = true
        # collation      = "Latin1_General_100_CI_AI_SC_UTF8"
        collation                   = "Latin1_General_100_BIN2_UTF8"
        create_mode                 = "Default"
        is_enabled                  = true
        sku_name                    = "DW100c"
        suffix                      = "sqlpool01"
        synapse_integration_runtime = "AzureIntegrationRuntime01"
      }
    ]

    integration_runtimes = [
      {
        name             = "AzureIntegrationRuntime01"
        compute_type     = "General"
        core_count       = 8
        time_to_live_min = 15
        is_enabled       = true
      }
    ]
  }
]
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
```hcl
string
```

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

## Aufruf der Module

### Base Module

```hcl
module "base" {
  source = "./modules/000_base"

  # Project related variables
  client_ips               = var.client_ips
  constants                = var.constants
  environment_is_private   = var.environment_is_private
  hub_subnet_gateway_id    = var.hub_subnet_gateway_id
  hub_vnet_id              = var.hub_vnet_id
  local_deployment_enabled = var.local_deployment_enabled
  location                 = var.location
  on_premises_networks     = var.on_premises_networks
  private_dns_zones        = var.private_dns_zones
  project                  = var.project
  role_assignment_enabled  = var.role_assignment_enabled
  security_groups          = var.security_groups
  tags                     = var.tags
  virtual_network          = var.virtual_network

  # Module related variables
  aacc            = var.aacc
  app_insights    = var.app_insights
  key_vault       = var.key_vault
  log_analytics   = var.log_analytics
  module_enabled  = false
  resource_groups = var.resource_groups
  strg_log        = var.strg_log
}
```

### Storage Module für Storage Accounts

```hcl
module "storage" {
  count  = length(var.strg)
  source = "./modules/100_storage"

  # Project related variables
  client_ips               = var.client_ips
  constants                = var.constants
  environment_is_private   = var.environment_is_private
  hub_subnet_gateway_id    = var.hub_subnet_gateway_id
  local_deployment_enabled = var.local_deployment_enabled
  location                 = var.location
  on_premises_networks     = var.on_premises_networks
  private_dns_zones        = var.private_dns_zones
  project                  = var.project
  role_assignment_enabled  = var.role_assignment_enabled
  security_groups          = var.security_groups
  virtual_network          = var.virtual_network

  # Module related variables
  module_enabled  = false
  resource_groups = var.resource_groups
  strg            = var.strg[count.index]

  # dependency does not work, deploy each module separately!
  # depends_on = [module.base.dependencies]
}
```

### Database Modul

```hcl
module "database" {
  count  = length(var.mssql_server)
  source = "./modules/200_database"

  client_ips               = var.client_ips
  constants                = var.constants
  environment_is_private   = var.environment_is_private
  hub_subnet_gateway_id    = var.hub_subnet_gateway_id
  local_deployment_enabled = var.local_deployment_enabled
  location                 = var.location
  on_premises_networks     = var.on_premises_networks
  private_dns_zones        = var.private_dns_zones
  project                  = var.project
  role_assignment_enabled  = var.role_assignment_enabled
  security_groups          = var.security_groups
  virtual_network          = var.virtual_network

  # Module related variables
  module_enabled          = false
  mssql_server            = var.mssql_server[count.index]
  resource_groups         = var.resource_groups
  sql_aad_admin_login     = var.sql_aad_admin_login
  sql_aad_admin_object_id = var.sql_aad_admin_object_id
  sql_aad_admin_password  = var.sql_aad_admin_password
  sql_admin_login         = var.sql_admin_login
  sql_admin_password      = var.sql_admin_password

  # dependency does not work, deploy each module separately!
  # depends_on = [module.base.dependencies]
}
```

### Integration Modul

```hcl
module "integration" {
  count  = length(var.data_factory)
  source = "./modules/700_integration"

  client_ips               = var.client_ips
  constants                = var.constants
  environment_is_private   = var.environment_is_private
  hub_subnet_gateway_id    = var.hub_subnet_gateway_id
  local_deployment_enabled = var.local_deployment_enabled
  location                 = var.location
  on_premises_networks     = var.on_premises_networks
  private_dns_zones        = var.private_dns_zones
  project                  = var.project
  role_assignment_enabled  = var.role_assignment_enabled
  security_groups          = var.security_groups
  virtual_network          = var.virtual_network

  # Module related variables
  module_enabled         = false
  resource_groups        = var.resource_groups
  data_factory           = var.data_factory[count.index]
  sql_aad_admin_login    = var.sql_aad_admin_login
  sql_aad_admin_password = var.sql_aad_admin_password

  # dependency does not work, deploy each module separately!
  # depends_on = [
  #   module.base.dependencies,
  #   module.storage_bbs01.dependencies,
  #   module.storage_dfs01.dependencies,
  #   module.database_mssql_server_01.dependencies
  # ]
}
```

### Streaming Modul
```hcl
module "streaming" {
  count  = length(var.streaming)
  source = "./modules/400_streaming"

  client_ips               = var.client_ips
  environment_is_private   = var.environment_is_private
  hub_subnet_gateway_id    = var.hub_subnet_gateway_id
  local_deployment_enabled = var.local_deployment_enabled
  location                 = var.location
  on_premises_networks     = var.on_premises_networks
  private_dns_zone_id      = var.private_dns_zone_id
  private_dns_zones        = var.private_dns_zones
  project                  = var.project
  role_assignment_enabled  = var.role_assignment_enabled
  security_groups          = var.security_groups
  virtual_network          = var.virtual_network

  # Module related variables
  eventhub_namespace = var.streaming[count.index].eventhub_namespace
  iothub             = var.streaming[count.index].iothub
  module_enabled     = false
  resource_groups    = var.resource_groups

  # dependency does not work, deploy each module separately!
  # depends_on = [
  #   module.base.dependencies,
  #   module.storage.dependencies,
  # ]
}
```

### Synapse Modul

```hcl
module "synapse_workspace" {
  count  = length(var.synapse_workspace)
  source = "./modules/800_synapse"

  client_ips               = var.client_ips
  constants                = var.constants
  environment_is_private   = var.environment_is_private
  hub_subnet_gateway_id    = var.hub_subnet_gateway_id
  local_deployment_enabled = var.local_deployment_enabled
  location                 = var.location
  on_premises_networks     = var.on_premises_networks
  private_dns_zones        = var.private_dns_zones
  project                  = var.project
  role_assignment_enabled  = var.role_assignment_enabled
  security_groups          = var.security_groups
  virtual_network          = var.virtual_network

  # Module related variables
  module_enabled                  = false
  resource_groups                 = var.resource_groups
  sql_aad_admin_login             = var.sql_aad_admin_login
  sql_aad_admin_password          = var.sql_aad_admin_password
  sql_admin_login                 = var.sql_admin_login
  sql_admin_password              = var.sql_admin_password
  synapse_aad_admin_login         = var.synapse_aad_admin_login
  synapse_aad_admin_object_id     = var.synapse_aad_admin_object_id
  synapse_sql_aad_admin_login     = var.synapse_sql_aad_admin_login
  synapse_sql_aad_admin_object_id = var.synapse_sql_aad_admin_object_id
  synapse_workspace               = var.synapse_workspace[count.index]

  # dependency does not work, deploy each module separately!
  # depends_on = [
  #   module.base.dependencies,
  #   module.storage_bbs01.dependencies,
  #   module.storage_dfs01.dependencies,
  #   module.database_mssql_server_01.dependencies
  # ]
}
```

---
&#129044; [Terraform Hub](07_Terraform_Hub.md) &ensp;|&ensp; &#129045; [Inhaltsverzeichnis](00_Inhaltsverzeichnis.md) &ensp;|&ensp; [Terraform Spoke Module Base](07_Terraform_Spoke_Module_Base.md) &#129046;