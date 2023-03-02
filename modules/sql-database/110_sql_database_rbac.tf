locals {
  rbac_mssql_server = flatten([
    for security_group_key, security_group in var.security_groups : [
      for object_key, object_id in security_group.object_ids : [
        for role_key, role in security_group.role_assignments.mssql_server : {
          key                = "${lower(replace(security_group.name, " ", "_"))}.${lower(replace(role, " ", "_"))}.${lower(replace(azurerm_mssql_server.this.name, " ", "_"))}.${object_key}"
          security_group_key = security_group_key
          role_key           = role_key
          resource_key       = azurerm_mssql_server.this.name
          name               = security_group.name
          object_id          = object_id
          role               = role
          scope              = azurerm_mssql_server.this.id
        }
    ]]
  ])
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "log_storage_account" {
  scope                = var.log_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_mssql_server.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "mssql_server" {
  for_each = {
    for o in local.rbac_mssql_server : o.key => o
  }

  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = each.value.object_id
}
