# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server
resource "azurerm_mssql_server" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-sqlsrv"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  version             = var.mssql_server.version

  azuread_administrator {
    login_username              = var.sql_aad_admin_login
    object_id                   = var.sql_aad_admin_object_id
    azuread_authentication_only = var.mssql_server.azuread_authentication_only
  }

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = var.mssql_server.public_network_access_enabled

  lifecycle {
    ignore_changes = [
      administrator_login_password,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_elasticpool
resource "azurerm_mssql_elasticpool" "this" {
  count = var.mssql_server.elastic_pool != null ? 1 : 0

  name                = "${azurerm_mssql_server.this.name}-pool"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  server_name         = azurerm_mssql_server.this.name
  license_type        = contains(["BusinessCritical", "GeneralPurpose"], var.mssql_server.elastic_pool.sku_tier) ? var.mssql_server.elastic_pool.license_type : null
  max_size_gb         = var.mssql_server.elastic_pool.max_size_gb

  sku {
    name     = var.mssql_server.elastic_pool.sku_name
    tier     = var.mssql_server.elastic_pool.sku_tier
    family   = var.mssql_server.elastic_pool.sku_family
    capacity = var.mssql_server.elastic_pool.sku_capacity
  }

  per_database_settings {
    min_capacity = var.mssql_server.elastic_pool.per_database_settings_min_capacity
    max_capacity = var.mssql_server.elastic_pool.per_database_settings_max_capacity
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database
resource "azurerm_mssql_database" "this" {
  for_each = {
    for o in var.mssql_server.databases : lower(replace(o.name, " ", "_")) => o
  }

  name            = each.value.name
  server_id       = azurerm_mssql_server.this.id
  collation       = each.value.collation
  elastic_pool_id = var.mssql_server.elastic_pool != null ? azurerm_mssql_elasticpool.this[0].id : null
  sku_name        = var.mssql_server.elastic_pool != null ? "ElasticPool" : each.value.sku_name

  tags = {
    "linked_service" = each.value.linked_service
  }
}
