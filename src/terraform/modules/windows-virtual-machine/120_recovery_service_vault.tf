# Note: Disable softe delete of Recover Service Vault before destruction
# az backup vault backup-properties set --soft-delete-feature-state Disable --name azc-iac-vse-rsv
# Portal: Properties -> Security Settings -> Update -> Disable
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault
resource "azurerm_recovery_services_vault" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-rsv"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  identity {
    type = "SystemAssigned"
  }

  sku = "Standard"

  lifecycle {
    ignore_changes = [
      soft_delete_enabled
    ]
  }
}
