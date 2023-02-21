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

  default = {
    name             = "ClientIP01"
    cidr             = "93.228.115.13/32"
    start_ip_address = "93.228.115.13"
    end_ip_address   = "93.228.115.13"
  }

  description = "Client IP."
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Client secret of the service principal."
}

variable "dns_zone_blob_id" {
  type        = string
  description = "Id of the private DNS zone for the Storage Blob."
}

variable "dns_zone_dfs_id" {
  type        = string
  description = "Id of the private DNS zone for the Storage Data Lake Gen2."
}

variable "dns_zone_file_id" {
  type        = string
  description = "Id of the private DNS zone for the Storage File."
}

variable "dns_zone_queue_id" {
  type        = string
  description = "Id of the private DNS zone for the Storage Queue."
}

variable "dns_zone_table_id" {
  type        = string
  description = "Id of the private DNS zone for the Storage Table."
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

variable "storage_account" {
  type = list(object({
    account_kind             = optional(string)
    account_replication_type = string
    account_tier             = string
    is_hns_enabled           = optional(bool, false)
    suffix                   = string

    private_endpoints = list(string)
  }))

  default = [
    {
      account_tier             = "Standard"
      account_replication_type = "LRS"
      suffix                   = "blob"

      private_endpoints = [
        "blob",
        "table"
      ]
    },
    {
      account_tier             = "Standard"
      account_replication_type = "LRS"
      is_hns_enabled           = true
      suffix                   = "adls"

      private_endpoints = [
        "blob",
        "dfs"
      ]
    }
  ]

  description = "Configuration of Azure Storage Account"
}

variable "subnet_id" {
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
