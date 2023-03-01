locals {
  rbac_synapse_workspace = flatten([
    for security_group_key, security_group in var.security_groups : [
      for object_key, object_id in security_group.object_ids : [
        for role_key, role in security_group.role_assignments.synapse_workspace : {
          key                = "${lower(replace(security_group.name, " ", "_"))}.${lower(replace(role, " ", "_"))}.${lower(replace(azurerm_synapse_workspace.this.name, " ", "_"))}.${object_key}"
          security_group_key = security_group_key
          role_key           = role_key
          resource_key       = azurerm_synapse_workspace.this.name
          name               = security_group.name
          object_id          = object_id
          role               = role
          scope              = azurerm_synapse_workspace.this.id
        }
    ]]
  ])
}

# https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep
# Delay the creation of the resources. Might be necessary to wait for the creation of the firewall rules.
# Note: Not fully evaluated.
resource "time_sleep" "this" {
  depends_on = [
    azurerm_synapse_firewall_rule.azure_ips,
    azurerm_synapse_firewall_rule.agent_ip
  ]

  create_duration = "60s"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "key_vault_azure_synapse" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_synapse_workspace.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_account_azure_synapse" {
  scope                = var.log_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.this.identity[0].principal_id
}

resource "azurerm_synapse_role_assignment" "synapse_workspace" {
  for_each = {
    for o in local.rbac_synapse_workspace : o.key => o
  }

  synapse_workspace_id = each.value.scope
  role_name            = each.value.role
  principal_id         = each.value.object_id

  depends_on = [
    time_sleep.this
  ]
}
