
# Configure the Azure Provider
provider "azurerm" { }

# Create a resource group
resource "azurerm_resource_group" "network" {
  name     = "${var.prefix}_resource_group"
  location = "${var.region}"
  tags = {project = "${var.project_tag}"}
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "network" {
  name                = "${var.prefix}-vnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.network.location}"
  resource_group_name = "${azurerm_resource_group.network.name}"
  tags = {project = "${var.project_tag}"}

  subnet {
    name           = "${var.prefix}-subnet1"
    address_prefix = "10.0.1.0/24"
  }
}

# Create a storage account
resource "azurerm_storage_account" "storage" {
  name = "${var.prefix}storage"
  location            = "${azurerm_resource_group.network.location}"
  resource_group_name = "${azurerm_resource_group.network.name}"
  account_replication_type = "ZRS"
  enable_https_traffic_only = false
  account_tier = "Standard"
  access_tier = "hot"
  tags = {project = "${var.project_tag}"}
}

# Create a storage container
resource "azurerm_storage_container" "container" {
  name = "${var.prefix}-container"
  resource_group_name = "${azurerm_resource_group.network.name}"
  storage_account_name = "${azurerm_storage_account.storage.name}"
  container_access_type = "private"
}

