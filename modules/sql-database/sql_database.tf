# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "this" {
  name     = "${var.project.customer}-${var.project.name}-${var.project.environment}-rg-sqldb"
  location = var.location
  tags     = var.tags
}

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

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_network_rule
resource "azurerm_mssql_virtual_network_rule" "this" {
  count = var.hub_subnet_gateway_id != null ? 1 : 0

  name      = "${azurerm_mssql_server.this.name}-vnr"
  server_id = azurerm_mssql_server.this.id
  subnet_id = var.hub_subnet_gateway_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule
resource "azurerm_mssql_firewall_rule" "this" {
  name             = "Allow Azure Services"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
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
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "this" {
  scope                = var.log_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_mssql_server.this.identity[0].principal_id
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy
resource "azurerm_mssql_server_extended_auditing_policy" "this" {
  server_id              = azurerm_mssql_server.this.id
  enabled                = true
  storage_endpoint       = var.log_primary_blob_endpoint
  retention_in_days      = 30
  log_monitoring_enabled = false

  depends_on = [
    azurerm_role_assignment.this
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy
resource "azurerm_mssql_database_extended_auditing_policy" "this" {
  for_each = {
    for o in var.mssql_server.databases : lower(replace(o.name, " ", "_")) => o
  }

  database_id            = "${azurerm_mssql_server.this.id}/databases/${each.value.name}"
  enabled                = true
  storage_endpoint       = var.log_primary_blob_endpoint
  retention_in_days      = 30
  log_monitoring_enabled = false

  depends_on = [
    azurerm_mssql_server.this,
    azurerm_mssql_database.this,
    azurerm_mssql_server_extended_auditing_policy.this
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting
resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = {
    for o in var.mssql_server.databases : lower(replace(o.name, " ", "_")) => o
  }

  name                           = "Diagnostics"
  log_analytics_destination_type = "AzureDiagnostics"
  # log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  storage_account_id = var.log_storage_account_id
  target_resource_id = "${azurerm_mssql_server.this.id}/databases/${each.value.name}"


  dynamic "enabled_log" {
    for_each = toset(["DevOpsOperationsAudit", "SQLSecurityAuditEvents"])

    content {
      category = enabled_log.key

      retention_policy {
        enabled = true
        days    = 30
      }
    }
  }

  depends_on = [
    azurerm_mssql_database.this
  ]

  lifecycle {
    ignore_changes = [
      enabled_log,
      metric,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "this" {
  name                = "${azurerm_mssql_server.this.name}-prep"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_database_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_database_id]
  }

  private_service_connection {
    name                           = "${azurerm_mssql_server.this.name}-prep-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlserver"]
  }
}
