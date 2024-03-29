# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = [var.virtual_network.address_space]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "shared_services" {
  name                 = "${var.project.customer}-${var.project.name}-${var.project.environment}-sn-${var.virtual_network.subnets.shared_services.name}"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.virtual_network.subnets.shared_services.address_space]
}

resource "azurerm_subnet" "virtual_machines" {
  name                 = "${var.project.customer}-${var.project.name}-${var.project.environment}-sn-${var.virtual_network.subnets.virtual_machines.name}"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.virtual_network.subnets.virtual_machines.address_space]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "${var.project.customer}-${var.project.name}-${var.project.environment}-sn-${var.virtual_network.subnets.private_endpoints.name}"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.virtual_network.subnets.private_endpoints.address_space]
  //enforce_private_link_endpoint_network_policies = true

  service_endpoints = [
    "Microsoft.AzureCosmosDB",
    "Microsoft.CognitiveServices",
    "Microsoft.EventHub",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus",
    "Microsoft.Sql",
    "Microsoft.Storage",
    "Microsoft.Web"
  ]
}

resource "azurerm_subnet" "databricks_private" {
  name                 = "${var.project.customer}-${var.project.name}-${var.project.environment}-sn-${var.virtual_network.subnets.databricks_private.name}"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.virtual_network.subnets.databricks_private.address_space]

  delegation {
    name = "Microsoft.Databricks.workspaces"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

resource "azurerm_subnet" "databricks_public" {
  name                 = "${var.project.customer}-${var.project.name}-${var.project.environment}-sn-${var.virtual_network.subnets.databricks_public.name}"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.virtual_network.subnets.databricks_public.address_space]

  delegation {
    name = "Microsoft.Databricks.workspaces"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "dlz_to_clz" {
  count = var.clz_virtual_network_id != null ? 1 : 0

  name                      = "${var.project.customer}-${var.project.name}-vnetpeer-clz"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.this.name
  remote_virtual_network_id = var.clz_virtual_network_id
  use_remote_gateways       = var.clz_subnet_gateway_id != null ? true : false
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "clz_to_dlz" {
  count = var.clz_virtual_network_name != null ? 1 : 0

  name                      = "${var.project.customer}-${var.project.name}-vnetpeer-dlz"
  resource_group_name       = var.clz_network_resource_group_name
  virtual_network_name      = var.clz_virtual_network_name
  remote_virtual_network_id = azurerm_virtual_network.this.id
  allow_gateway_transit     = var.clz_subnet_gateway_id != null ? true : false

  depends_on = [
    azurerm_virtual_network_peering.dlz_to_clz
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "shared_services" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-nsg-sn-${var.virtual_network.subnets.shared_services.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
}

resource "azurerm_network_security_group" "virtual_machines" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-nsg-sn-${var.virtual_network.subnets.virtual_machines.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
}

resource "azurerm_network_security_group" "private_endpoints" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-nsg-sn-${var.virtual_network.subnets.private_endpoints.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
}

resource "azurerm_network_security_group" "databricks_private" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-nsg-sn-${var.virtual_network.subnets.databricks_private.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
}

resource "azurerm_network_security_group" "databricks_public" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-nsg-sn-${var.virtual_network.subnets.databricks_public.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "shared_services" {
  subnet_id                 = azurerm_subnet.shared_services.id
  network_security_group_id = azurerm_network_security_group.shared_services.id
}

resource "azurerm_subnet_network_security_group_association" "virtual_machine" {
  subnet_id                 = azurerm_subnet.virtual_machines.id
  network_security_group_id = azurerm_network_security_group.virtual_machines.id
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}

resource "azurerm_subnet_network_security_group_association" "databricks_private" {
  subnet_id                 = azurerm_subnet.databricks_private.id
  network_security_group_id = azurerm_network_security_group.databricks_private.id
}

resource "azurerm_subnet_network_security_group_association" "databricks_public" {
  subnet_id                 = azurerm_subnet.databricks_public.id
  network_security_group_id = azurerm_network_security_group.databricks_public.id
}
