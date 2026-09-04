output "resource_group_name" {
  description = "Name of the lab resource group."
  value       = azurerm_resource_group.lab.name
}

output "virtual_network_name" {
  description = "Name of the lab virtual network."
  value       = azurerm_virtual_network.lab.name
}

output "virtual_network_address_space" {
  description = "Address space assigned to the lab virtual network."
  value       = azurerm_virtual_network.lab.address_space
}

output "management_subnet_id" {
  description = "Resource ID of the management subnet."
  value       = azurerm_subnet.management.id
}

output "server_subnet_id" {
  description = "Resource ID of the server subnet."
  value       = azurerm_subnet.servers.id
}

output "management_vm_name" {
  description = "Name of the Windows management VM."
  value       = azurerm_windows_virtual_machine.management.name
}

output "management_private_ip" {
  description = "Private IPv4 address assigned to the management VM."
  value       = azurerm_network_interface.management.private_ip_address
}

output "management_public_ip" {
  description = "Public IPv4 address used for restricted management access."
  value       = azurerm_public_ip.management.ip_address
}