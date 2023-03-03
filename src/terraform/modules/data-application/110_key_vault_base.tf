# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "this" {
  name                          = "${var.project.customer}-${var.project.name}-${var.project.environment}-kv-da"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  sku_name                      = "standard"
  tenant_id                     = data.azurerm_client_config.client_config.tenant_id

  network_acls {
    default_action = "Deny"
    bypass         = "None"
  }
}
