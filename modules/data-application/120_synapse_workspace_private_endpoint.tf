# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_private_link_hub
resource "azurerm_synapse_private_link_hub" "this" {
  name                = "${replace(azurerm_synapse_workspace.this.name, "-", "")}plh"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "sql" {
  name                = "${azurerm_synapse_workspace.this.name}-prep-sql"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_sql_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_sql_id]
  }

  private_service_connection {
    name                           = "${azurerm_synapse_workspace.this.name}-prep-sql-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    subresource_names              = ["SQL"]
  }
}

resource "azurerm_private_endpoint" "prep_synapse_workspace_sqlondemand" {
  name                = "${azurerm_synapse_workspace.this.name}-prep-sqlondemand"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_sql_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_sql_id]
  }

  private_service_connection {
    name                           = "${azurerm_synapse_workspace.this.name}-prep-sqlondemand-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    subresource_names              = ["SqlOnDemand"]
  }
}

resource "azurerm_private_endpoint" "dev" {
  name                = "${azurerm_synapse_workspace.this.name}-prep-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_dev_azuresynapse_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_dev_azuresynapse_id]
  }

  private_service_connection {
    name                           = "${azurerm_synapse_workspace.this.name}-prep-dev-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    subresource_names              = ["Dev"]
  }
}

resource "azurerm_private_endpoint" "web" {
  name                = "${azurerm_synapse_workspace.this.name}-prep-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_azuresynapse_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_azuresynapse_id]
  }

  private_service_connection {
    name                           = "${azurerm_synapse_workspace.this.name}-prep-web-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_private_link_hub.this.id
    subresource_names              = ["Web"]
  }
}
