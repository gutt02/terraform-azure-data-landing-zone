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

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "kv" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.client_config.object_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "kv" {
  name                = "${azurerm_key_vault.this.name}-prep"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_vaultcore_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_vaultcore_id]
  }

  private_service_connection {
    name                           = "${azurerm_key_vault.this.name}-prep-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
  }
}
