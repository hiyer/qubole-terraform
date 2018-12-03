# String to assign to created resources
variable "prefix" {}
variable "region" {
  default = "East US"
}

# Map of tags to assign to resources
variable "tags" {
  type = "map"

  default = {}
}

# vnet cidr
variable "vnet_cidr" {
  default = "10.0.0.0/16"
}

# subnet cidr
variable "subnet_cidr" {
  default = "10.0.0.0/24"
}

output "vnet_name" {
  value = "azurerm_virtual_network.network.name"
}

output "vnet_id" {
  value = "${azurerm_virtual_network.network.id}"
}

output "subnet_name" {
  value = "${azurerm_subnet.subnet.name}"
}

output "subnet_id" {
  value = "${azurerm_subnet.subnet.id}"
}

output "storage_account" {
  value = "${azurerm_storage_account.storage.name}"
}

output "primary_access_key" {
  value = "${azurerm_storage_account.storage.primary_access_key}"
}

output "storage_container" {
  value = "${azurerm_storage_container.container.name}"
}

output "defloc_prefix" {
  value = "${azurerm_storage_container.container.name}@${azurerm_storage_account.storage.name}.blob.core.windows.net"
}

