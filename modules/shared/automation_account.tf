# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account
resource "azurerm_automation_account" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-aacc"
  location            = var.location
  resource_group_name = azurerm_resource_group.mgmt.name

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = false

  sku_name = "Basic"
}

# The automation account needs read access to the subscription to log in.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "automation_account" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Reader"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "automation_account" {
  name                = "${azurerm_automation_account.this.name}-prep"
  location            = var.location
  resource_group_name = azurerm_resource_group.mgmt.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_azure_automation_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_azure_automation_id]
  }

  private_service_connection {
    name                           = "${azurerm_automation_account.this.name}-prep-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_automation_account.this.id
    subresource_names = [
      # "Webhook",
      "DSCAndHybridWorker"
    ]
  }
}
