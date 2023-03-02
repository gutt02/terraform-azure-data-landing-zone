# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_firewall_rule
resource "azurerm_synapse_firewall_rule" "azure_ips" {
  name                 = "AllowAllWindowsAzureIps"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "0.0.0.0"
}

resource "azurerm_synapse_firewall_rule" "agent_ip" {
  name                 = "AllowAgentIps"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  start_ip_address     = var.agent_ip
  end_ip_address       = var.agent_ip
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_extended_auditing_policy
resource "azurerm_synapse_workspace_extended_auditing_policy" "this" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  storage_endpoint     = var.log_primary_blob_endpoint
  retention_in_days    = 30

  depends_on = [
    azurerm_role_assignment.log_storage_account
  ]
}
