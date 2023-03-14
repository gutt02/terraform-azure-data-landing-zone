# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_service
resource "azurerm_log_analytics_linked_service" "this" {
  resource_group_name = azurerm_resource_group.mgmt.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  read_access_id      = azurerm_automation_account.this.id
}

