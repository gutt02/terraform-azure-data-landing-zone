# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/iothub
resource "azurerm_iothub" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-iothub"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  sku {
    name     = var.iothub.sku_name
    capacity = var.iothub.sku_capacity
  }

  identity {
    type = "SystemAssigned"
  }

  network_rule_set {
    default_action = "Deny"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "prep_iothub" {
  name                = "${azurerm_iothub.this.name}-prep"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_azure_devices_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_azure_devices_id]
  }

  private_service_connection {
    name                           = "${azurerm_iothub.this.name}-prep-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_iothub.this.id
    subresource_names              = ["iotHub"]
  }
}
