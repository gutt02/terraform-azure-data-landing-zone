# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "network" {
  name     = "${var.project.customer}-${var.project.name}-${var.project.environment}-rg-network"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "mgmt" {
  name     = "${var.project.customer}-${var.project.name}-${var.project.environment}-rg-mgmt"
  location = var.location
  tags     = var.tags
}
