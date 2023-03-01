# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "this" {
  name                     = "${var.project.customer}${var.project.name}${var.project.environment}sasynws"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }

  is_hns_enabled = true
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules
resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id = azurerm_storage_account.this.id
  default_action     = "Deny"
  bypass             = toset(["AzureServices"])
  ip_rules           = [var.agent_ip]
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "storage_account_sp" {
  for_each = {
    for o in toset(["Storage Account Contributor", "Storage Blob Data Contributor"]) : lower(replace(o, " ", "_")) => o
  }

  scope                = azurerm_storage_account.this.id
  role_definition_name = each.value
  principal_id         = data.azurerm_client_config.client_config.object_id
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_filesystem
resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  name               = "${var.project.customer}${var.project.name}${var.project.environment}synws"
  storage_account_id = azurerm_storage_account.this.id

  depends_on = [
    azurerm_storage_account_network_rules.this,
    azurerm_role_assignment.storage_account_sp
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace
resource "azurerm_synapse_workspace" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-synws"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  aad_admin {
    login     = var.synapse_aad_admin_login
    object_id = var.synapse_aad_admin_object_id
    tenant_id = data.azurerm_client_config.client_config.tenant_id
  }

  identity {
    type = "SystemAssigned"
  }

  managed_resource_group_name          = "${var.project.customer}-${var.project.name}-${var.project.environment}-rg-shared-synapse"
  managed_virtual_network_enabled      = true
  public_network_access_enabled        = true
  sql_identity_control_enabled         = true
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.this.id

  lifecycle {
    ignore_changes = [
      sql_administrator_login,
      sql_administrator_login_password,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_integration_runtime_azure
resource "azurerm_synapse_integration_runtime_azure" "this" {
  for_each = {
    for o in var.synapse_workspace.integration_runtimes : lower(replace(o.name, " ", "_")) => o if var.synapse_workspace.integration_runtimes != null
  }

  name                 = each.value.name
  location             = var.location
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  compute_type         = each.value.compute_type
  core_count           = each.value.core_count
  time_to_live_min     = each.value.time_to_live_min
}
