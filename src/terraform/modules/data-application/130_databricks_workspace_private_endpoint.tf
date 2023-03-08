# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_private_link_hub
resource "azurerm_private_endpoint" "databricks_workspace_ui_api" {
  name                = "${azurerm_databricks_workspace.this.name}-prep-ui-api"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_azuredatabricks_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_azuredatabricks_id]
  }

  private_service_connection {
    name                           = "${azurerm_databricks_workspace.this.name}-prep-ui-api-psc"
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
    subresource_names              = ["databricks_ui_api"]
  }
}
