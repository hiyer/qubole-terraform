variable "tags" {
  type = "map"
  description = "Map of tags to attach to security group and instance"
}

variable "whitelist_ip" {
  type = "list"
  description = "List of IPs to whitelist SSH from"
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

variable "num_subnets" {
  type = "string"
  description = "Number of public subnets to create"
  default = "1"
}