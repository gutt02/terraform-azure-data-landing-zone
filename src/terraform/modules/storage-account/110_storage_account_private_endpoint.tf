# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "blob" {
  for_each = {
    for o in var.storage_account : o.suffix => o if contains(o.private_endpoints, "blob")
  }

  name                = "${azurerm_storage_account.this[each.key].name}-prep-blob"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_blob_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_blob_id]
  }

  private_service_connection {
    name                           = "${azurerm_storage_account.this[each.key].name}-prep-blob-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.this[each.key].id
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_endpoint" "dfs" {
  for_each = {
    for o in var.storage_account : o.suffix => o if contains(o.private_endpoints, "dfs")
  }

  name                = "${azurerm_storage_account.this[each.key].name}-prep-dfs"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_dfs_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_dfs_id]
  }

  private_service_connection {
    name                           = "${azurerm_storage_account.this[each.key].name}-prep-dfs-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.this[each.key].id
    subresource_names              = ["dfs"]
  }
}

resource "azurerm_private_endpoint" "file" {
  for_each = {
    for o in var.storage_account : o.suffix => o if contains(o.private_endpoints, "file")
  }

  name                = "${azurerm_storage_account.this[each.key].name}-prep-file"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_file_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_file_id]
  }

  private_service_connection {
    name                           = "${azurerm_storage_account.this[each.key].name}-prep-file-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.this[each.key].id
    subresource_names              = ["file"]
  }
}

resource "azurerm_private_endpoint" "queue" {
  for_each = {
    for o in var.storage_account : o.suffix => o if contains(o.private_endpoints, "queue")
  }

  name                = "${azurerm_storage_account.this[each.key].name}-prep-queue"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_queue_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_queue_id]
  }

  private_service_connection {
    name                           = "${azurerm_storage_account.this[each.key].name}-prep-queue-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.this[each.key].id
    subresource_names              = ["queue"]
  }
}

resource "azurerm_private_endpoint" "table" {
  for_each = {
    for o in var.storage_account : o.suffix => o if contains(o.private_endpoints, "table")
  }

  name                = "${azurerm_storage_account.this[each.key].name}-prep-table"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_table_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_table_id]
  }

  private_service_connection {
    name                           = "${azurerm_storage_account.this[each.key].name}-prep-table-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.this[each.key].id
    subresource_names              = ["table"]
  }
}
