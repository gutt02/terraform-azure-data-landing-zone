locals {
  # detect OS
  # Directories start with "C:..." on Windows; All other OSs use "/" for root.
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

variable "automation_account_name" {
  type        = string
  description = "Name of the Automation Account."
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
    cidr             = "62.153.146.84/32"
    start_ip_address = "62.153.146.84"
    end_ip_address   = "62.153.146.84"
  }

  description = "Client IP."
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Client secret of the service principal."
}

variable "clz_subnet_gateway_id" {
  type        = string
  default     = null
  description = "Id of the Gateway in the connectivity landing zone (Hub)."
}

variable "dns_zone_azuresynapse_id" {
  type        = string
  description = "Id of the private DNS zone for Azure Synapse Web."
}

variable "dns_zone_azuredatabricks_id" {
  type        = string
  description = "Id of the private DNS zone for Azure Databricks."
}

variable "dns_zone_azuredatabricks_id_be" {
  type        = string
  description = "Id of the private DNS zone for Azure Databricks for the backend (data landing zone)."
}

variable "dns_zone_sql_id" {
  type        = string
  description = "Id of the private DNS zone for Azure Synapse SQL."
}

variable "dns_zone_dev_azuresynapse_id" {
  type        = string
  description = "Id of the private DNS zone for Azure Synapse Dev."
}

variable "dns_zone_vaultcore_id" {
  type        = string
  description = "Id of the private DNS zone for the Key Vault."
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

variable "mgmt_resource_group_name" {
  type        = string
  description = "Name of the Management Resourcegroup."
}

variable "network_security_group_association_databricks_private_id" {
  type        = string
  description = "Id of the Network Security Association of the private subnet."
}

variable "network_security_group_association_databricks_public_id" {
  type        = string
  description = "Id of the Network Security Association of the public subnet."
}

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
      cidr             = "10.0.0.0/24"
      start_ip_address = "10.0.0.0"
      end_ip_address   = "10.0.0.255"
    }
  ]

  description = "List of on-premises networks."
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
    environment = "acf"
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
      object_ids = ["ed07b095-7809-48c8-8ae7-df71184102be"]
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
      object_ids = ["fd1b8b2a-3132-4495-bff1-659f749e8f6e"]
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
      object_ids = ["dfce96dd-2542-4dbc-9416-1886a1a3b8dc"]
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
      object_ids = ["8928fb7e-424b-4c84-b8dd-a62f7598f904"]
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

variable "subnet_databricks_private_id" {
  type        = string
  description = "Id of the private subnet for Azure Databricks"
}

variable "subnet_databricks_private_name" {
  type        = string
  description = "Name of the private subnet for Azure Databricks"
}

variable "subnet_databricks_public_id" {
  type        = string
  description = "Id of the public subnet for Azure Databricks"
}

variable "subnet_databricks_public_name" {
  type        = string
  description = "Name of the public subnet for Azure Databricks"
}

variable "subnet_private_endpoints_id" {
  type        = string
  description = "Id of the subnet for the private endpoints."
}

variable "synapse_aad_admin_login" {
  type        = string
  default     = null
  description = "Azure Active Directory Azure Synapse Analytics Admininstrator login"
}

variable "synapse_aad_admin_object_id" {
  type        = string
  default     = null
  description = "Azure Active Directory Azure Synapse Analytics Analytics Admininstrator object id"
}

variable "synapse_workspace" {
  type = object({
    spark_pools = optional(list(object({
      auto_pause_delay_in_minutes = number
      auto_scale_max_node_count   = number
      auto_scale_min_node_count   = number
      cache_size                  = number
      name                        = string
      node_size                   = string
      node_size_family            = string
      spark_version               = string
    })))

    sql_pools = optional(list(object({
      auto_pause     = string
      data_encrypted = bool
      collation      = string
      create_mode    = string
      sku_name       = string
      name           = string
    })))

    integration_runtimes = optional(list(object({
      name             = string
      compute_type     = string
      core_count       = number
      time_to_live_min = number
    })))
  })

  default = {
    spark_pools = [
      {
        auto_pause_delay_in_minutes = 15
        auto_scale_max_node_count   = 10
        auto_scale_min_node_count   = 3
        cache_size                  = 100
        name                        = "SparkPool01"
        node_size                   = "Small"
        node_size_family            = "MemoryOptimized"
        spark_version               = "3.2"
      }
    ]

    sql_pools = [
      {
        auto_pause     = "enabled"
        collation      = "SQL_Latin1_General_CP1_CI_AS"
        create_mode    = "Default"
        data_encrypted = true
        name           = "SqlPool01"
        sku_name       = "DW100c"
      }
    ]

    integration_runtimes = [{
      compute_type     = "General"
      core_count       = 8
      name             = "AzHIRSmall"
      time_to_live_min = 15
    }]
  }

  description = "Configuration of Azure Synapse Analytics Workspace."
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
    created_by  = "azc-iac-payg-sp-tf"
    contact     = "contact@me"
    customer    = "Azure Cloud"
    environment = "Visual Studio Enterprise"
    project     = "Data Landing Zone"
  }

  description = "Default tags for resources, only applied to resource groups."
}

variable "virtual_network_id" {
  type        = string
  description = "Id of the Virtual Network."
}
