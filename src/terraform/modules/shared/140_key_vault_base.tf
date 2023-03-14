# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "this" {
  name                      = "${var.project.customer}-${var.project.name}-${var.project.environment}-kv"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.mgmt.name
  enable_rbac_authorization = true
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.client_config.tenant_id

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [var.client_ip.cidr, var.agent_ip]
  }
}
