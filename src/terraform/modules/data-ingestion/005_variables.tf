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

variable "clz_subnet_gateway_id" {
  type        = string
  default     = null
  description = "Id of the Gateway in the Hub."
}

variable "data_factory" {
  type = object({
    managed_virtual_network_enabled = optional(bool, false)
    public_network_enabled          = bool

    integration_runtimes = optional(list(object({
      name                    = string
      compute_type            = string
      core_count              = number
      time_to_live_min        = number
      virtual_network_enabled = optional(bool, false)
    })))
  })

  default = {
    managed_virtual_network_enabled = true
    public_network_enabled          = false

    integration_runtimes = [
      {
        compute_type            = "General"
        core_count              = 8
        name                    = "AzHIRSmall"
        time_to_live_min        = 15
        virtual_network_enabled = true
      }
    ]
  }

  description = "Configuration of Azure Data Factory."
}

variable "dns_zone_adf_id" {
  type        = string
  description = "Id of the private DNS zone for the Data Factory Portal."
}

variable "dns_zone_azure_devices_id" {
  type        = string
  description = "Id of the private DNS zone for the IotHub."
}

variable "dns_zone_datafactory_id" {
  type        = string
  description = "Id of the private DNS zone for the Data Factory."
}

variable "dns_zone_servicebus_id" {
  type        = string
  description = "Id of the private DNS zone for the Service Bus."
}

variable "dns_zone_vaultcore_id" {
  type        = string
  description = "Id of the private DNS zone for the Key Vault."
}

variable "eventhub_namespace" {
  type = object({
    sku      = string
    capacity = optional(number)

    eventhubs = list(object({
      capture_description_enabled     = optional(bool)
      capture_description_encoding    = optional(string)
      destination_archive_name_format = optional(string)
      destination_blob_container_name = optional(string)
      name                            = string
      message_retention               = number
      partition_count                 = number
    }))
  })

  default = {
    sku = "Standard"

    eventhubs = [
      {
        capture_description_enabled     = false
        capture_description_encoding    = "Avro"
        destination_archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
        destination_blob_container_name = "evhub01"
        message_retention               = 1
        name                            = "evhub01"
        partition_count                 = 2
      }
    ]
  }

  description = "Configuration of the Eventhub Namesapce."
}

variable "iothub" {
  type = object({
    sku_name     = string
    sku_capacity = string
  })

  default = {
    sku_capacity = "1"
    sku_name     = "F1"
  }

  description = "Configuration of the Iothub."
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
      object_ids = ["161b5111-f7f8-491e-b719-7d452500d1f1"]
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
      object_ids = ["8381e24c-e540-4349-b801-4938c857ffdf"]
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
      object_ids = ["33a274c1-556d-43fd-b133-5262f97212f2"]
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
      object_ids = ["ed09ccea-947c-4beb-b37e-1f2d2e11a554"]
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
