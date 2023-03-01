# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "this" {
  for_each = {
    for o in var.storage_account : o.suffix => o
  }

  name                     = "${var.project.customer}${var.project.name}${var.project.environment}${each.value.suffix}"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  account_kind             = each.value.account_kind
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type

  identity {
    type = "SystemAssigned"
  }

  is_hns_enabled = each.value.is_hns_enabled
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules
resource "azurerm_storage_account_network_rules" "this" {
  for_each = {
    for o in var.storage_account : o.suffix => o
  }

  storage_account_id         = azurerm_storage_account.this[each.key].id
  default_action             = "Deny"
  bypass                     = toset(["AzureServices"])
  virtual_network_subnet_ids = var.hub_subnet_gateway_id != null ? [var.hub_subnet_gateway_id] : []
}
