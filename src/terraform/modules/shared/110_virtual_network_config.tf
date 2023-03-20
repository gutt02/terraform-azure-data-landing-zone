# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule
resource "azurerm_network_security_rule" "this" {
  name                        = "AllowCidrBlockVirtualMachineInBound"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "3389"]
  source_address_prefix       = var.client_ip.cidr
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}
