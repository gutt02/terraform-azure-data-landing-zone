# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_sql_pool
resource "azurerm_synapse_sql_pool" "this" {
  for_each = {
    for o in var.synapse_workspace.sql_pools : lower(replace(o.name, " ", "_")) => o if var.synapse_workspace.sql_pools != null
  }

  name                 = each.value.name
  collation            = each.value.collation
  create_mode          = each.value.create_mode
  data_encrypted       = each.value.data_encrypted
  sku_name             = each.value.sku_name
  synapse_workspace_id = azurerm_synapse_workspace.this.id

  tags = {
    auto_pause = each.value.auto_pause
  }

  lifecycle {
    ignore_changes = [
      sku_name
    ]
  }
}
