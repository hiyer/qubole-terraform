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