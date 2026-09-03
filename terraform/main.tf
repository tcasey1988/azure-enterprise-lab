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