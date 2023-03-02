# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_network_rule
resource "azurerm_mssql_virtual_network_rule" "this" {
  count = var.hub_subnet_gateway_id != null ? 1 : 0

  name      = "${azurerm_mssql_server.this.name}-vnr"
  server_id = azurerm_mssql_server.this.id
  subnet_id = var.hub_subnet_gateway_id
}

# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule
# resource "azurerm_mssql_firewall_rule" "this" {
#   name             = "Allow Azure Services"
#   server_id        = azurerm_mssql_server.this.id
#   start_ip_address = "0.0.0.0"
#   end_ip_address   = "0.0.0.0"
# }

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy
resource "azurerm_mssql_server_extended_auditing_policy" "this" {
  server_id              = azurerm_mssql_server.this.id
  enabled                = true
  storage_endpoint       = var.log_primary_blob_endpoint
  retention_in_days      = 30
  log_monitoring_enabled = false

  depends_on = [
    azurerm_role_assignment.log_storage_account
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
    azurerm_mssql_database.this,
    azurerm_role_assignment.log_storage_account
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
      log_analytics_destination_type,
      enabled_log,
      metric,
    ]
  }
}
