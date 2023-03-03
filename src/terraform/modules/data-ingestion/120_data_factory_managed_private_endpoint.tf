# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_managed_private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_data_factory_managed_private_endpoint" "blob" {
  for_each = {
    for o in data.azurerm_storage_account.storage_account : lower(replace(o.name, " ", "_")) => o if !o.is_hns_enabled
  }

  name               = "${each.value.name}-prep-blob"
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = each.value.id
  subresource_name   = "blob"

  lifecycle {
    ignore_changes = [
      fqdns
    ]
  }
}

resource "azurerm_data_factory_managed_private_endpoint" "dfs" {
  for_each = {
    for o in data.azurerm_storage_account.storage_account : lower(replace(o.name, " ", "_")) => o if o.is_hns_enabled
  }

  name               = "${each.value.name}-prep-dfs"
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = each.value.id
  subresource_name   = "dfs"

  lifecycle {
    ignore_changes = [
      fqdns
    ]
  }
}

resource "azurerm_data_factory_managed_private_endpoint" "sqlserver" {
  for_each = {
    for o in data.azurerm_mssql_server.mssql_server : lower(replace(o.name, " ", "_")) => o
  }

  name               = "${each.value.name}-prep"
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = each.value.id
  subresource_name   = "sqlserver"

  lifecycle {
    ignore_changes = [
      fqdns
    ]
  }
}
