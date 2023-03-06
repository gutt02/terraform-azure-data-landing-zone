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

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}
