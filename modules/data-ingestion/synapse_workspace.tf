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
  public_network_access_enabled        = false
  sql_identity_control_enabled         = true
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.this.id

  lifecycle {
    ignore_changes = [
      sql_administrator_login_password,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_sql_pool
resource "azurerm_synapse_sql_pool" "this" {
  for_each = {
    for o in var.synapse_workspace.sql_pools : lower(replace(o.name, " ", "_")) => o if var.synapse_workspace.sql_pools != null
  }

  name                 = each.value.name
  collation            = each.value.collation
  create_mode          = each.value.create_mode
  data_encrypted       = each.value.data_encrypted
  sku_name             = each.value.sku_name
  synapse_workspace_id = azurerm_synapse_workspace.this.id

  tags = {
    auto_pause = each.value.auto_pause
  }

  lifecycle {
    ignore_changes = [
      sku_name
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool
resource "azurerm_synapse_spark_pool" "this" {
  for_each = {
    for o in var.synapse_workspace.spark_pools : lower(replace(o.name, " ", "_")) => o if var.synapse_workspace.spark_pools != null
  }

  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  node_size_family     = each.value.node_size_family
  node_size            = each.value.node_size

  auto_pause {
    delay_in_minutes = each.value.auto_pause_delay_in_minutes
  }

  auto_scale {
    max_node_count = each.value.auto_scale_max_node_count
    min_node_count = each.value.auto_scale_min_node_count
  }

  cache_size    = each.value.cache_size
  spark_version = each.value.spark_version

  #   library_requirement {
  #     content  = <<EOF
  # appnope==0.1.0
  # beautifulsoup4==4.6.3
  # EOF
  #     filename = "requirements.txt"
  #   }

  #   spark_config {
  #     content  = <<EOF
  # spark.shuffle.spill                true
  # EOF
  #     filename = "config.txt"
  #   }
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

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service
resource "azurerm_synapse_linked_service" "key_vault" {
  name                 = azurerm_key_vault.this.name
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureKeyVault"

  type_properties_json = <<JSON
{
  "baseUrl": "${azurerm_key_vault.this.vault_uri}"
}
JSON

  depends_on = [
    azurerm_synapse_integration_runtime_azure.this
  ]
}
