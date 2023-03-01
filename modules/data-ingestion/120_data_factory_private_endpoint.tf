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
