locals {
  # detect OS
  # Directories start with "C:..." on Windows; All other OSs use "/" for root.
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

# curl ipinfo.io/ip
variable "agent_ip" {
  type        = string
  description = "IP of the deployment agent."
}

# curl ipinfo.io/ip
variable "client_ip" {
  type = object({
    name             = string
    cidr             = string
    start_ip_address = string
    end_ip_address   = string
  })

  description = "Client IP."
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Client secret of the service principal."
}

variable "dns_zone_database_id" {
  type        = string
  description = "Id of the private DNS zone for the SQL database."
}

variable "hub_subnet_gateway_id" {
  type        = string
  default     = null
  description = "Id of the Gateway in the Hub."
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Default Azure region, use Azure CLI notation."
}

variable "log_primary_blob_endpoint" {
  type        = string
  description = "Primary Blob endpoint of the Log Storage Account."
}

variable "log_storage_account_id" {
  type        = string
  description = "Id of the Log Storage Account."
}

variable "mssql_server" {
  type = object({
    azuread_authentication_only   = bool
    public_network_access_enabled = bool
    version                       = string

    elastic_pool = optional(object({
      license_type                       = string
      max_size_gb                        = number
      sku_name                           = string
      sku_tier                           = string
      sku_family                         = string
      sku_capacity                       = number
      per_database_settings_min_capacity = number
      per_database_settings_max_capacity = number
    }))

    databases = optional(list(object({
      name           = string
      collation      = string
      linked_service = optional(string, "disabled")
      sku_name       = string
    })))
  })

  default = {
    azuread_authentication_only   = true
    public_network_access_enabled = true
    version                       = "12.0"

    elastic_pool = {
      license_type                       = "LicenseIncluded"
      max_size_gb                        = 9.7656250
      sku_name                           = "BasicPool"
      sku_tier                           = "Basic"
      sku_family                         = null
      sku_capacity                       = 100
      per_database_settings_min_capacity = 0
      per_database_settings_max_capacity = 5
    }

    databases = [
      {
        name           = "DBSDLZVSE01"
        collation      = "SQL_Latin1_General_CP1_CI_AS"
        linked_service = "enabled"
        sku_name       = "Basic"
      }
    ]
  }

  description = "Configuration of Azure SQL Server and databases."
}

// See ASY nets here: https://ipinfo.io/AS33873
variable "on_premises_networks" {
  type = list(object({
    name             = string
    cidr             = string
    start_ip_address = string
    end_ip_address   = string
  }))

  default = [
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

  description = "List of ASY networks, https://ipinfo.io/AS33873."
}

variable "project" {
  type = object({
    customer    = string
    name        = string
    environment = string
  })

  default = {
    customer    = "azc"
    name        = "dlz"
    environment = "vse"
  }

  description = "Project details, like customer name, environment, etc."
}

# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
# https://docs.microsoft.com/en-us/azure/key-vault/general/rbac-guide
# https://docs.microsoft.com/en-us/azure/synapse-analytics/security/synapse-workspace-synapse-rbac-roles
variable "security_groups" {
  type = list(object({
    name       = string
    object_ids = list(string)

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

  default = [
    {
      # Data and Platform Engineer
      name       = "data_platform_engineer"
      object_ids = ["161b5111-f7f8-491e-b719-7d452500d1f1"] # mysvc_sg
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
      name       = "data_analyst"
      object_ids = ["8381e24c-e540-4349-b801-4938c857ffdf"] # sg
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
      name       = "data_scientist"
      object_ids = ["33a274c1-556d-43fd-b133-5262f97212f2"] # jk
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
      name       = "data_steward"
      object_ids = ["ed09ccea-947c-4beb-b37e-1f2d2e11a554"] # sl
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

  description = "RBAC and key vault access policy for Azure Active Directory security groups and users."
}

variable "sql_aad_admin_login" {
  type        = string
  description = "Azure Active Directory SQL Admin login"
}

variable "sql_aad_admin_object_id" {
  type        = string
  description = "Azure Active Directory SQL Admin object id"
}

variable "subnet_private_endpoints_id" {
  type        = string
  description = "Id of the subnet for the private endpoints."
}

variable "tags" {
  type = object({
    created_by  = string
    contact     = string
    customer    = string
    environment = string
    project     = string
  })

  default = {
    created_by  = "vsp-base-msdn-sp-tf"
    contact     = "contact@me"
    customer    = "Azure Cloud"
    environment = "Visual Studio Enterprise"
    project     = "Data Landing Zone"
  }

  description = "Default tags for resources, only applied to resource groups"
}
