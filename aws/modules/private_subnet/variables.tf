variable "tags" {
  type = "map"
  description = "Map of tags to attach to security group and instance"
}

variable "whitelist_outgoing" {
  type = "string"
  description = "IP to whitelist outgoing traffic to"
}

variable "prefix" {
  type = "string"
  description = "Prefix for 'name' tag"
}

variable "vpc_id" {
  type = "string"
  description = "VPC Id"
}

variable "subnet_cidr" {
  type = "string"
  description = "CIDR for the subnet"
}