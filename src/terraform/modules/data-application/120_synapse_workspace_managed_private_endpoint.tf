# https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep
# Delay the creation of the resources. Might be necessary to wait for the creation of the firewall rules.
# Note: Not fully evaluated.
resource "time_sleep" "delay_managed_private_endpoint" {
  depends_on = [
    azurerm_synapse_firewall_rule.agent_ip
  ]

  create_duration = "60s"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_managed_private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_synapse_managed_private_endpoint" "blob" {
  for_each = {
    for o in data.azurerm_storage_account.storage_account : lower(replace(o.name, " ", "_")) => o if !o.is_hns_enabled
  }

  name                 = "${each.value.name}-prep-blob"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = each.value.id
  subresource_name     = "blob"

  depends_on = [
    time_sleep.delay_managed_private_endpoint
  ]
}

resource "azurerm_synapse_managed_private_endpoint" "dfs" {
  for_each = {
    for o in data.azurerm_storage_account.storage_account : lower(replace(o.name, " ", "_")) => o if o.is_hns_enabled
  }

  name                 = "${each.value.name}-prep-dfs"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = each.value.id
  subresource_name     = "dfs"

  depends_on = [
    time_sleep.delay_managed_private_endpoint
  ]
}

resource "azurerm_synapse_managed_private_endpoint" "database" {
  for_each = {
    for o in data.azurerm_mssql_server.mssql_server : lower(replace(o.name, " ", "_")) => o
  }

  name                 = "${each.value.name}-prep"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  target_resource_id   = each.value.id
  subresource_name     = "sqlserver"

  depends_on = [
    time_sleep.delay_managed_private_endpoint
  ]
}
