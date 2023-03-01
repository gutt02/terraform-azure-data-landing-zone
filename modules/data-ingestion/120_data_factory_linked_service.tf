# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_key_vault
resource "azurerm_data_factory_linked_service_key_vault" "this" {
  name            = azurerm_key_vault.this.name
  data_factory_id = azurerm_data_factory.this.id
  key_vault_id    = azurerm_key_vault.this.id

  depends_on = [
    azurerm_data_factory_integration_runtime_azure.data_factory_integration_runtime_azure
  ]
}
