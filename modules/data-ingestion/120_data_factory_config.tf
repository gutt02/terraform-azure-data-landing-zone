# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting
resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting_data_factory" {
  name                           = "Diagnostics"
  log_analytics_destination_type = "AzureDiagnostics"
  storage_account_id             = var.log_storage_account_id
  target_resource_id             = azurerm_data_factory.this.id

  dynamic "enabled_log" {
    for_each = toset(["ActivityRuns", "PipelineRuns", "TriggerRuns"])

    content {
      category = enabled_log.key

      retention_policy {
        enabled = true
        days    = 30
      }
    }
  }

  lifecycle {
    ignore_changes = [
      log_analytics_destination_type,
      enabled_log,
      metric,
    ]
  }
}
