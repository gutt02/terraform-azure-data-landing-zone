# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-la"
  location            = var.location
  resource_group_name = azurerm_resource_group.mgmt.name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights
resource "azurerm_application_insights" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-appinsights"
  location            = var.location
  resource_group_name = azurerm_resource_group.mgmt.name
  application_type    = "other"
  workspace_id        = azurerm_log_analytics_workspace.this.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "this" {
  name                     = "${var.project.customer}${var.project.name}${var.project.environment}salog"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.mgmt.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules
resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id         = azurerm_storage_account.this.id
  default_action             = "Deny"
  bypass                     = toset(["AzureServices"])
  virtual_network_subnet_ids = var.clz_subnet_gateway_id != null ? [var.clz_subnet_gateway_id] : []
}
