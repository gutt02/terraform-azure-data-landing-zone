# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_storage_account
resource "azurerm_log_analytics_linked_storage_account" "this" {
  for_each = {
    for o in toset(["CustomLogs", "Query", "Alerts"]) : lower(o) => o
  }

  data_source_type      = each.value
  resource_group_name   = azurerm_resource_group.mgmt.name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  storage_account_ids   = [azurerm_storage_account.this.id]

  lifecycle {
    ignore_changes = [
      # Terraform requires lower case whereas Azure uses CamelCase
      data_source_type
    ]
  }
}
