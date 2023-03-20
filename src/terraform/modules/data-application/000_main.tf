terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.42.0"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    template_deployment {
      delete_nested_items_during_deletion = false
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}

provider "databricks" {
  host                        = azurerm_databricks_workspace.this.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.this.id
  azure_client_id             = data.azurerm_client_config.client_config.client_id
  azure_client_secret         = var.client_secret
  azure_tenant_id             = data.azurerm_client_config.client_config.tenant_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config
data "azurerm_client_config" "client_config" {
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription
data "azurerm_subscription" "subscription" {
}
