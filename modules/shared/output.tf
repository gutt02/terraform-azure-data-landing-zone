output "subnet_private_endpoints_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}
