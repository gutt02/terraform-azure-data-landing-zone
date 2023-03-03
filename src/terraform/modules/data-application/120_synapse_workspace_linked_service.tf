# https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep
# Delay the creation of the resources. Might be necessary to wait for the creation of the firewall rules.
# Note: Not fully evaluated.
resource "time_sleep" "delay_linked_services" {
  depends_on = [
    azurerm_synapse_firewall_rule.azure_ips,
    azurerm_synapse_firewall_rule.agent_ip
  ]

  create_duration = "60s"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service
resource "azurerm_synapse_linked_service" "key_vault" {
  name                 = azurerm_key_vault.this.name
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureKeyVault"

  type_properties_json = jsonencode({
    "baseUrl" = "${azurerm_key_vault.this.vault_uri}"
  })

  depends_on = [
    azurerm_synapse_integration_runtime_azure.this,
    time_sleep.delay_linked_services
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service
resource "azurerm_synapse_linked_service" "blob" {
  for_each = {
    for o in data.azurerm_storage_account.storage_account : lower(replace(o.name, " ", "_")) => o if !o.is_hns_enabled
  }

  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureBlobStorage"

  type_properties_json = jsonencode({
    "serviceEndpoint" = "${each.value.primary_blob_endpoint}"
  })

  depends_on = [
    time_sleep.delay_linked_services
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service
resource "azurerm_synapse_linked_service" "dfs" {
  for_each = {
    for o in data.azurerm_storage_account.storage_account : lower(replace(o.name, " ", "_")) => o if o.is_hns_enabled
  }

  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureBlobFS"

  type_properties_json = jsonencode({
    "url" = "${each.value.primary_dfs_endpoint}"
  })

  depends_on = [
    time_sleep.delay_linked_services
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service
resource "azurerm_synapse_linked_service" "database" {
  for_each = {
    for o in local.database : lower(replace(o.key, " ", "_")) => o
  }

  name                 = each.value.mssql_database.name
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureSqlDatabase"

  type_properties_json = jsonencode({
    "connectionString" = "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=${each.value.mssql_server.fully_qualified_domain_name};Initial Catalog=${each.value.mssql_database.name};"
  })

  depends_on = [
    time_sleep.delay_linked_services
  ]
}
