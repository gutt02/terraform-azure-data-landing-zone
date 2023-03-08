# # Creating a databricks metastore is not possible with Terraform as long as the Service Principal is not an account admin.
# # The first account admin is the Azure Active Directory Global Administrator who can than assign users to account admins.
# # https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/get-started#requirements

# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_access_connector
# resource "azurerm_databricks_access_connector" "this" {
#   name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-dbac"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.this.name

#   identity {
#     type = "SystemAssigned"
#   }
# }

# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
# resource "azurerm_storage_account" "unity_catalog" {
#   name                     = "${var.project.customer}${var.project.name}${var.project.environment}sadbwsuc"
#   location                 = var.location
#   resource_group_name      = azurerm_resource_group.this.name
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
#   is_hns_enabled           = true
# }

# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules
# resource "azurerm_storage_account_network_rules" "unity_catalog" {
#   storage_account_id = azurerm_storage_account.unity_catalog.id
#   default_action     = "Deny"
#   bypass             = toset(["AzureServices"])
#   ip_rules           = [var.agent_ip]
# }

# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
# resource "azurerm_role_assignment" "unity_catalog_service_principal" {
#   for_each = {
#     for o in toset(["Storage Account Contributor", "Storage Blob Data Contributor"]) : lower(replace(o, " ", "_")) => o
#   }

#   scope                = azurerm_storage_account.unity_catalog.id
#   role_definition_name = each.value
#   principal_id         = data.azurerm_client_config.client_config.object_id
# }

# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container
# resource "azurerm_storage_container" "unity_catalog" {
#   name                  = "unity-catalog"
#   storage_account_name  = azurerm_storage_account.unity_catalog.name
#   container_access_type = "private"

#   depends_on = [
#     azurerm_role_assignment.unity_catalog_service_principal
#   ]
# }

# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
# resource "azurerm_role_assignment" "access_connector" {
#   scope                = azurerm_storage_account.unity_catalog.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
# }

# # Requires the creation of the Databricks Workspace
# # https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/group
# data "databricks_group" "this" {
#   display_name = "admins"
# }

# # https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal
# data "databricks_service_principal" "this" {
#   application_id = data.azurerm_client_config.client_config.client_id
# }

# # https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/service_principal
# resource "databricks_group_member" "this" {
#   group_id  = data.databricks_group.this.id
#   member_id = data.databricks_service_principal.this.id
# }

# # https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore
# resource "databricks_metastore" "this" {
#   name = "primary"

#   storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
#     azurerm_storage_container.unity_catalog.name,
#   azurerm_storage_account.unity_catalog.name)

#   force_destroy = true
#   owner         = data.azurerm_client_config.client_config.client_id

#   depends_on = [
#     azurerm_role_assignment.access_connector,
#     databricks_group_member.this
#   ]
# }

# # https://registry.terraform.io/providers/databricks/databricks/1.11.1/docs/resources/metastore_assignment
# resource "databricks_metastore_assignment" "this" {
#   metastore_id = databricks_metastore.this.id
#   workspace_id = azurerm_databricks_workspace.this.workspace_id
# }
