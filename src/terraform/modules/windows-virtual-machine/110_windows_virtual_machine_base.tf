# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
resource "azurerm_key_vault_secret" "this" {
  name         = var.admin_username
  value        = random_password.this.result
  key_vault_id = var.key_vault_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "this" {
  name                = "${var.project.customer}${var.project.name}${var.project.environment}wvm-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  allocation_method = "Dynamic"
  domain_name_label = "${var.project.customer}${var.project.name}${var.project.environment}wvm"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "this" {
  name                = "${var.project.customer}${var.project.name}${var.project.environment}wvm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "IpConfig"
    subnet_id                     = var.subnet_virtual_machines_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
resource "azurerm_windows_virtual_machine" "this" {
  name                = "${var.project.customer}${var.project.name}${var.project.environment}wvm"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  admin_username = var.admin_username
  admin_password = random_password.this.result

  identity {
    type = "SystemAssigned"
  }

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  os_disk {
    name                 = "${var.project.customer}${var.project.name}${var.project.environment}wvm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  size = var.windows_virtual_machine.size

  source_image_reference {
    publisher = var.windows_virtual_machine.source_image_reference.publisher
    offer     = var.windows_virtual_machine.source_image_reference.offer
    sku       = var.windows_virtual_machine.source_image_reference.sku
    version   = var.windows_virtual_machine.source_image_reference.version
  }

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk
resource "azurerm_managed_disk" "this" {
  name                = "${azurerm_windows_virtual_machine.this.name}-datadisk"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  create_option        = "Empty"
  disk_size_gb         = "128"
  storage_account_type = "StandardSSD_LRS"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment
resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  managed_disk_id    = azurerm_managed_disk.this.id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = "0"
  caching            = "ReadOnly"
}
