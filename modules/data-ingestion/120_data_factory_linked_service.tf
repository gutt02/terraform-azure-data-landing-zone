# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_key_vault
resource "azurerm_data_factory_linked_service_key_vault" "this" {
  name            = azurerm_key_vault.this.name
  data_factory_id = azurerm_data_factory.this.id
  key_vault_id    = azurerm_key_vault.this.id

  depends_on = [
    azurerm_data_factory_integration_runtime_azure.data_factory_integration_runtime_azure
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_azure_blob_storage
resource "azurerm_data_factory_linked_service_azure_blob_storage" "this" {
  for_each = {
    for o in data.azurerm_storage_account.storage_account : lower(replace(o.name, " ", "_")) => o if !o.is_hns_enabled
  }

  name                     = each.value.name
  data_factory_id          = azurerm_data_factory.this.id
  service_endpoint         = each.value.primary_blob_endpoint
  storage_kind             = each.value.account_kind
  use_managed_identity     = true
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_data_lake_storage_gen2
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "this" {
  for_each = {
    for o in data.azurerm_storage_account.storage_account : lower(replace(o.name, " ", "_")) => o if o.is_hns_enabled
  }

  name                     = each.value.name
  data_factory_id          = azurerm_data_factory.this.id
  url                      = "https://${each.value.name}.dfs.core.windows.net/"
  use_managed_identity     = true
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_azure_sql_database
resource "azurerm_data_factory_linked_service_azure_sql_database" "this" {
  for_each = {
    for o in local.database : lower(replace(o.key, " ", "_")) => o
  }

  name                     = each.value.mssql_database.name
  data_factory_id          = azurerm_data_factory.this.id
  connection_string        = "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=${each.value.mssql_server.fully_qualified_domain_name};Initial Catalog=${each.value.mssql_database.name};"
  use_managed_identity     = true
}
