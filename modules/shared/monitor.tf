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
  bypass                     = toset(["None"])
  virtual_network_subnet_ids = var.hub_subnet_gateway_id != null ? [var.hub_subnet_gateway_id] : []
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_storage_account
resource "azurerm_log_analytics_linked_storage_account" "this" {
  for_each = {
    for o in toset(["CustomLogs", "Query", "Alerts"]) : lower(o) => o
  }

  data_source_type      = each.value
  resource_group_name   = azurerm_resource_group.mgmt.name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  storage_account_ids   = [azurerm_storage_account.this.id]

  lifecycle {
    ignore_changes = [
      # Terraform requires lower case whereas Azure uses CamelCase
      data_source_type
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_private_link_scope
resource "azurerm_monitor_private_link_scope" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-pls"
  resource_group_name = azurerm_resource_group.mgmt.name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_private_link_scoped_service
resource "azurerm_monitor_private_link_scoped_service" "log_analytics" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-amplsservice-la"
  resource_group_name = azurerm_resource_group.mgmt.name
  scope_name          = azurerm_monitor_private_link_scope.this.name
  linked_resource_id  = azurerm_log_analytics_workspace.this.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_private_link_scoped_service
resource "azurerm_monitor_private_link_scoped_service" "application_insights" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-plss-appinsights"
  resource_group_name = azurerm_resource_group.mgmt.name
  scope_name          = azurerm_monitor_private_link_scope.this.name
  linked_resource_id  = azurerm_application_insights.this.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "monitor_private_link_scope" {
  name                = "${azurerm_monitor_private_link_scope.this.name}-prep"
  location            = var.location
  resource_group_name = azurerm_resource_group.mgmt.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_dns_zone_group {
    name = replace(var.dns_zone_monitor_id, "/.*[/]/", "")
    private_dns_zone_ids = [
      var.dns_zone_agentsvc_azure_automation_id,
      var.dns_zone_blob_id,
      var.dns_zone_monitor_id,
      var.dns_zone_ods_opinsights_id,
      var.dns_zone_oms_opinsights_id
    ]
  }

  private_service_connection {
    name                           = "${azurerm_monitor_private_link_scope.this.name}-prep-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_monitor_private_link_scope.this.id
    subresource_names              = ["azuremonitor"]
  }

  depends_on = [
    azurerm_monitor_private_link_scoped_service.log_analytics,
    azurerm_monitor_private_link_scoped_service.application_insights
  ]
}

resource "azurerm_private_endpoint" "storage_account" {
  name                = "${azurerm_storage_account.this.name}-prep-blob"
  location            = var.location
  resource_group_name = azurerm_resource_group.mgmt.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_blob_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_blob_id]
  }

  private_service_connection {
    name                           = "${azurerm_storage_account.this.name}-prep-blob-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
  }
}
