# The automation account needs read access to the subscription to log in.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "automation_account" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Reader"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}
