# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "this" {
  name     = "${var.project.customer}-${var.project.name}-${var.project.environment}-rg-storage"
  location = var.location
  tags     = var.tags
}

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

  # network_rules {
  #   default_action             = "Deny"
  #   bypass                     = toset(["AzureServices"])
  #   ip_rules                   = []
  #   virtual_network_subnet_ids = var.hub_subnet_gateway_id != null ? [var.hub_subnet_gateway_id] : []
  # }
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
