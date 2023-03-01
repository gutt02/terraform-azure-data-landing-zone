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
