# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "this" {
  name     = "${var.project.customer}-${var.project.name}-${var.project.environment}-rg-wvm"
  location = var.location
  tags     = var.tags
}
