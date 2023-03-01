# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service
resource "azurerm_synapse_linked_service" "key_vault" {
  name                 = azurerm_key_vault.this.name
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureKeyVault"

  type_properties_json = <<JSON
{
  "baseUrl": "${azurerm_key_vault.this.vault_uri}"
}
JSON

  depends_on = [
    azurerm_synapse_integration_runtime_azure.this
  ]
}
