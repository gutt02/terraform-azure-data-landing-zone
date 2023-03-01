# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account
resource "azurerm_automation_account" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-aacc"
  location            = var.location
  resource_group_name = azurerm_resource_group.mgmt.name

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = false
  sku_name                      = "Basic"
}
