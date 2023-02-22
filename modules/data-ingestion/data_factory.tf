# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory
resource "azurerm_data_factory" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-adf"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  identity {
    type = "SystemAssigned"
  }

  managed_virtual_network_enabled = var.data_factory.managed_virtual_network_enabled
  public_network_enabled          = var.data_factory.public_network_enabled
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_integration_runtime_azure
resource "azurerm_data_factory_integration_runtime_azure" "data_factory_integration_runtime_azure" {
  for_each = {
    for o in var.data_factory.integration_runtimes : lower(replace(o.name, " ", "_")) => o if var.data_factory.integration_runtimes != null
  }

  name             = each.value.name
  location         = var.location
  data_factory_id  = azurerm_data_factory.this.id
  compute_type     = each.value.compute_type
  core_count       = each.value.core_count
  time_to_live_min = each.value.time_to_live_min
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "key_vault_adf" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_account" {
  scope                = var.log_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_key_vault
resource "azurerm_data_factory_linked_service_key_vault" "this" {
  name            = azurerm_key_vault.this.name
  data_factory_id = azurerm_data_factory.this.id
  key_vault_id    = azurerm_key_vault.this.id

  depends_on = [
    azurerm_data_factory_integration_runtime_azure.data_factory_integration_runtime_azure
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting
resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting_data_factory" {
  name                           = "Diagnostics"
  log_analytics_destination_type = "AzureDiagnostics"
  storage_account_id             = var.log_storage_account_id
  target_resource_id             = azurerm_data_factory.this.id

  dynamic "enabled_log" {
    for_each = toset(["ActivityRuns", "PipelineRuns", "TriggerRuns"])

    content {
      category = enabled_log.key

      retention_policy {
        enabled = true
        days    = 30
      }
    }
  }

  lifecycle {
    ignore_changes = [
      enabled_log,
      metric,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "datafactory" {
  name                = "${azurerm_data_factory.this.name}-prep-datafactory"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_datafactory_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_datafactory_id]
  }

  private_service_connection {
    name                           = "${azurerm_data_factory.this.name}-prep-datafactory-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_data_factory.this.id
    subresource_names              = ["dataFactory"]
  }
}

resource "azurerm_private_endpoint" "portal" {
  name                = "${azurerm_data_factory.this.name}-prep-portal"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_adf_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_adf_id]
  }

  private_service_connection {
    name                           = "${azurerm_data_factory.this.name}-prep-portal-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_data_factory.this.id
    subresource_names              = ["portal"]
  }
}
