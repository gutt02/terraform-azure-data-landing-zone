# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace
resource "azurerm_eventhub_namespace" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-evhns"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.eventhub_namespace.sku
  capacity            = var.eventhub_namespace.capacity

  identity {
    type = "SystemAssigned"
  }

  dynamic "network_rulesets" {
    for_each = var.hub_subnet_gateway_id != null ? [var.hub_subnet_gateway_id] : []

    content {
      default_action                 = "Deny"
      public_network_access_enabled  = true
      trusted_service_access_enabled = true

      virtual_network_rule {
        subnet_id                                       = network_rulesets.value
        ignore_missing_virtual_network_service_endpoint = true
      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub
resource "azurerm_eventhub" "this" {
  for_each = {
    for o in var.eventhub_namespace.eventhubs : lower(replace(o.name, " ", "_")) => o
  }

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = azurerm_resource_group.this.name
  message_retention   = each.value.message_retention
  partition_count     = each.value.partition_count

  # capture_description {
  #   enabled  = each.value.capture_description_enabled
  #   encoding = each.value.capture_description_encoding

  #   destination {
  #     name                = "EventHubArchive.AzureBlockBlob"
  #     archive_name_format = each.value.destination_archive_name_format
  #     blob_container_name = each.value.destination_blob_container_name
  #     storage_account_id  = <storage_account_id>
  #   }
  # }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "eventhub_namespace" {
  name                = "${azurerm_eventhub_namespace.this.name}-prep"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_private_endpoints_id

  private_dns_zone_group {
    name                 = replace(var.dns_zone_servicebus_id, "/.*[/]/", "")
    private_dns_zone_ids = [var.dns_zone_servicebus_id]
  }

  private_service_connection {
    name                           = "${azurerm_eventhub_namespace.this.name}-prep-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_eventhub_namespace.this.id
    subresource_names              = ["namespace"]
  }
}
