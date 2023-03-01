# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "this" {
  name                = "${azurerm_mssql_server.this.name}-prep"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_database_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_database_id]
  }

  private_service_connection {
    name                           = "${azurerm_mssql_server.this.name}-prep-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlserver"]
  }
}
