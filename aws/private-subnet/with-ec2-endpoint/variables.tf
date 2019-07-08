variable "cidr_block" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "aws_key_name" {
  description = "Key Pair to use for the bastion node"
}

variable "prefix" {
  description = "Prefix to apply for name tags"
}

variable "tags" {
  type = map(string)

  default     = {}
  description = "Other tags to apply. It is *highly recommended* to specify tags so you can identify your resources."
}

variable "ssh_public_key" {
  description = "Public key to use for bastion node. This is the account key in cluster UI"
}

variable "region" {
  default     = "us-west-2"
  description = "AWS region"
}

variable "public_subnet_cidr" {
  default     = ""
  description = "CIDR for the public subnet. Auto-calculated if not specified. Ignored when using multiple subnets."
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
  description = "Number of private subnets to create for cluster nodes."
  default     = "1"
}

variable "whitelist_outgoing" {
  default     = ""
  description = "Public IP to whitelist outgoing traffic to. If not specified, no outgoing traffic is allowed from the private subnet except to s3 and ec2 via the respective vpc endpoints."
}

variable "bastion_node_instance_type" {
  type        = string
  description = "Instance type for bastion node"
  default     = "t3.small"
}

output "bastion_ip" {
  value       = module.bastion_node.public_ip
  description = "IP address of the bastion node"
}

output "vpc_id" {
  value       = aws_vpc.default.id
  description = "VPC Id"
}

output "private_subnet_id" {
  value       = module.private_subnet.subnet_ids
  description = "Private subnet Id(s)"
}

output "public_subnet_id" {
  value       = module.public_subnet.subnet_id
  description = "Public subnet Id"
}

output "vpc_endpoint" {
  value       = [aws_vpc_endpoint.ec2.dns_entry]
  description = "VPC EC2 Endpoint"
}

