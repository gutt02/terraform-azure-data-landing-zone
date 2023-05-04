# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "databricks_workspace_ui_api_be" {
  name                = "${azurerm_databricks_workspace.this.name}-prep-ui-api-be"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_azuredatabricks_id_be, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_azuredatabricks_id_be]
  }

  private_service_connection {
    name                           = "${azurerm_databricks_workspace.this.name}-prep-ui-api-be-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    subresource_names              = ["databricks_ui_api"]
  }
}

resource "azurerm_private_endpoint" "databricks_workspace_ui_api_fe" {
  name                = "${azurerm_databricks_workspace.this.name}-prep-ui-api-fe"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_azuredatabricks_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_azuredatabricks_id]
  }

  private_service_connection {
    name                           = "${azurerm_databricks_workspace.this.name}-prep-ui-api-fe-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    subresource_names              = ["databricks_ui_api"]
  }
}

resource "azurerm_private_endpoint" "databricks_workspace_browser_authentication" {
  name                = "${azurerm_databricks_workspace.this.name}-prep-browser-authentication"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_azuredatabricks_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_azuredatabricks_id]
  }

  private_service_connection {
    name                           = "${azurerm_databricks_workspace.this.name}-prep-browser-authentication-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    subresource_names              = ["browser_authentication"]
  }
}
