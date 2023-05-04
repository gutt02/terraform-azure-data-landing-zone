output "automation_account_name" {
  value = azurerm_automation_account.this.name
}

output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.workspace_id
}

output "log_analytics_workspace_primary_shared_key" {
  value     = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive = true
}

output "mgmt_resource_group_name" {
  value = azurerm_resource_group.mgmt.name
}

output "network_security_group_association_databricks_private_id" {
  value = azurerm_network_security_group.databricks_private.id
}

output "network_security_group_association_databricks_public_id" {
  value = azurerm_network_security_group.databricks_public.id
}

output "private_dns_zones" {
  value = tomap({
    for private_dns_zone_key, private_dns_zone_name in var.private_dns_zones : private_dns_zone_key => {
      name = private_dns_zone_name
      id   = azurerm_private_dns_zone.this[private_dns_zone_key].id
    }
  })
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
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

output "subnet_private_endpoints_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "subnet_virtual_machines_id" {
  value = azurerm_subnet.virtual_machines.id
}

output "subnet_virtual_machines_name" {
  value = azurerm_subnet.virtual_machines.name
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "virtual_network_id" {
  value = azurerm_virtual_network.this.id
}
