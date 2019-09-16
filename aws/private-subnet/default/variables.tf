variable "cidr_block" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "aws_key_name" {
  description = "Key Pair for the bastion node"
}

variable "prefix" {
  description = "Prefix to apply for name tags"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply on applicable resources It is *highly recommended* to specify tags so you can identify your resources."
  default     = {}
}

variable "ssh_public_key" {
  description = "SSH public key for SSH'ing into your bastion node. This is the Account key in the cluster details page"
}

variable "region" {
  default     = "us-west-2"
  description = "AWS Region"
}

variable "public_subnet_cidr" {
  default     = ""
  description = "CIDR for public subnet. Auto-calculated if not specified. Ignored when using multiple subnets."
}

variable "private_subnet_cidr" {
  default     = ""
  description = "CIDR for private subnet. Auto-calculated if not specified. Ignored when using multiple subnets."
}

variable "whitelist_ip" {
  type        = list(string)
  description = "List of IPs to whitelist SSH from"
}

variable "num_pvt_subnets" {
  type        = string
  description = "Number of private subnets to create for cluster nodes. Do not specify private_subnet_cidr if using multiple subnets"
  default     = "1"
}

variable "bastion_node_instance_type" {
  type        = string
  description = "Instance type for bastion node"
  default     = "t3.small"
}

variable "use_network_acls" {
  type        = bool
  description = "Whether to use network ACLs in addition to security groups for access control"
  default     = false
}

output "bastion_ip" {
  value       = module.bastion_node.public_ip
  description = "IP address of the bastion node"
}

output "bastion_id" {
  value       = module.bastion_node.instance_id
  description = "Instance Id of the bastion node"
}

output "vpc_id" {
  value       = aws_vpc.default.id
  description = "VPC Id"
}

output "private_subnet_id" {
  value       = module.private_subnet.subnet_ids
  description = "Private subnet id(s)"
}

output "public_subnet_id" {
  value       = module.public_subnet.subnet_id
  description = "Public subnet id"
}

