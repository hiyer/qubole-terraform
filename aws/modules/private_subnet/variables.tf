variable "tags" {
  type        = map(string)
  description = "Map of tags to attach to security group and instance"
}

variable "whitelist_outgoing" {
  type        = string
  description = "IP to whitelist outgoing traffic to"
}

variable "prefix" {
  type        = string
  description = "Prefix for 'name' tag"
}

variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR for the subnet"
}

variable "num_pvt_subnets" {
  type        = string
  description = "Number of private subnets to create"
  default     = 1
}

variable "use_network_acls" {
  type        = bool
  description = "Whether to use Network ACLs in addition to security groups for access control"
}
