variable "cidr_block" {
  default = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "aws_key_name" {
  description = "Key Pair for the bastion node"  
}

variable "prefix" {
  description = "Prefix to apply for name tags"  
}

variable "tags" {
  type = "map"
  description = "Tags to apply on applicable resources"
  default = {}
}

variable "ssh_public_key" {
  description = "SSH public key for SSH'ing into your bastion node. This is the Account key in the cluster details page"
}

variable "region" {
  default = "us-west-2"
  description = "AWS Region"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
  description = "CIDR for public subnet"
}

variable "private_subnet_cidr" {
  default = ""
  description = "CIDR for private subnet. Do not specify if using multiple subnets"
}

variable "whitelist_ip" {
  type = "list"
  description = "List of IPs to whitelist SSH from"
}

variable "num_pvt_subnets" {
  type = "string"
  description = "Number of private subnets to create for cluster nodes. Do not specify private_subnet_cidr if using multiple subnets"
  default = "1"
}


output "bastion_ip" {
  value = "${module.bastion_node.public_ip}"
  description = "IP address of the bastion node"
}

output "vpc_id" {
  value = "${aws_vpc.default.id}"
  description = "VPC Id"
}

output "private_subnet_id" {
  value = "${module.private_subnet.subnet_id}"
  description = "Private subnet id"
}

output "public_subnet_id" {
  value = "${module.public_subnet.subnet_id}"
  description = "Public subnet id"
}






