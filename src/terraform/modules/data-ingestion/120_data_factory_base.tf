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

  name                    = each.value.name
  location                = var.location
  data_factory_id         = azurerm_data_factory.this.id
  compute_type            = each.value.compute_type
  core_count              = each.value.core_count
  time_to_live_min        = each.value.time_to_live_min
  virtual_network_enabled = var.data_factory.managed_virtual_network_enabled && each.value.virtual_network_enabled
}
