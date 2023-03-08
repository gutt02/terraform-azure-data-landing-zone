output "automation_account_name" {
  value = azurerm_automation_account.this.name
}

output "mgmt_resource_group_name" {
  value = azurerm_resource_group.mgmt.name
}
output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "subnet_private_endpoints_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "subnet_databricks_private_id" {
  value = azurerm_subnet.databricks_private.id
}

output "subnet_databricks_private_name" {
  value = azurerm_subnet.databricks_public.name
}

output "subnet_databricks_public_id" {
  value = azurerm_subnet.databricks_public.id
}

output "subnet_databricks_public_name" {
  value = azurerm_subnet.databricks_public.name
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "network_security_group_association_databricks_private_id" {
  value = azurerm_network_security_group.databricks_private.id
}

output "network_security_group_association_databricks_public_id" {
  value = azurerm_network_security_group.databricks_public.id
}
output "virtual_network_id" {
  value = azurerm_virtual_network.this.id
}
