locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Thomas Casey"
  }
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-ael-${var.environment}"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-ael-${var.environment}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.20.0.0/16"]
  dns_servers         = ["10.20.2.10"]

  tags = local.common_tags
}

resource "azurerm_network_security_group" "management" {
  name                = "nsg-management"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  tags = local.common_tags
}

resource "azurerm_network_security_group" "servers" {
  name                = "nsg-servers"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  tags = local.common_tags
}

resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "servers" {
  name                 = "snet-servers"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.20.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.management.id
}

resource "azurerm_subnet_network_security_group_association" "servers" {
  subnet_id                 = azurerm_subnet.servers.id
  network_security_group_id = azurerm_network_security_group.servers.id
}

resource "azurerm_network_security_rule" "management_rdp" {
  name                        = "Allow-RDP-From-Admin"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = var.admin_source_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.management.name
}

resource "azurerm_public_ip" "management" {
  name                = "pip-ael-mgmt01"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

resource "azurerm_network_interface" "management" {
  name                = "nic-ael-mgmt01"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.management.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.20.1.10"
    public_ip_address_id          = azurerm_public_ip.management.id
  }

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "management" {
  name                = "vm-ael-mgmt01"
  computer_name       = "AEL-MGMT01"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  size                = var.management_vm_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.management.id
  ]

  os_disk {
    name                 = "osdisk-ael-mgmt01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }

  patch_assessment_mode = "AutomaticByPlatform"
  patch_mode            = "AutomaticByOS"

  tags = merge(local.common_tags, {
    Role = "Management"
  })
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "management" {
  virtual_machine_id = azurerm_windows_virtual_machine.management.id
  location           = azurerm_resource_group.lab.location
  enabled            = true

  daily_recurrence_time = "0500"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "domain_controller" {
  name                = "nic-ael-dc01"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.servers.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.20.2.10"
  }

  tags = merge(local.common_tags, {
    Role = "DomainController"
  })
}

resource "azurerm_windows_virtual_machine" "domain_controller" {
  name                = "vm-ael-dc01"
  computer_name       = "AEL-DC01"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  size                = var.management_vm_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.domain_controller.id
  ]

  os_disk {
    name                 = "osdisk-ael-dc01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }

  patch_assessment_mode = "AutomaticByPlatform"
  patch_mode            = "AutomaticByOS"

  tags = merge(local.common_tags, {
    Role = "DomainController"
  })
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "domain_controller" {
  virtual_machine_id = azurerm_windows_virtual_machine.domain_controller.id
  location           = azurerm_resource_group.lab.location
  enabled            = true

  daily_recurrence_time = "0500"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }

  tags = local.common_tags
}