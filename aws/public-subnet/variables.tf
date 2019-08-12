variable "cidr_block" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "prefix" {
  description = "Prefix to be used for 'name' tags. e.g. the vpc would be named _prefix_-vpc"
}

variable "tags" {
  type        = map(string)
  description = "Other tags to apply. It is *highly recommended* to specify tags so you can identify your resources."
  default     = {}
}

variable "region" {
  description = "AWS region to create the resources in"
  default     = "us-west-2"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the subnet. Auto-calculated if not specified. Ignored when using multiple subnets"
  default     = ""
}

variable "num_subnets" {
  type        = string
  description = "Number of subnets to create"
  default     = "1"
}

variable "whitelist_ip" {
  type        = list(string)
  description = "List of IPs to whitelist SSH from"
}

variable "use_network_acls" {
  type        = bool
  description = "Whether to use network ACLs in addition to security groups for access control"
  default     = false
}

output "vpc_id" {
  value       = aws_vpc.default.id
  description = "Id of the VPC"
}

output "public_subnet_ids" {
  value       = module.public_subnet.subnet_ids
  description = "Id of the public subnet(s)"
}

