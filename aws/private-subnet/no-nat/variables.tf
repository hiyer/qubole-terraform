variable "cidr_block" {
  default = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "aws_key_name" {
  description = "Key Pair to use for the bastion node"
}

variable "prefix" {
  description = "Prefix to apply for name tags"
}

variable "tags" {
  type = "map"

  default = {}
  description = "Other tags to apply"
}

variable "ssh_public_key" {
  description = "Public key to use for bastion node. This is the account key in cluster UI"
}

variable "region" {
  default = "us-west-2"
  description = "AWS region"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
  description = "CIDR for the public subnet"
}

variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
  description = "CIDR for the private subnet"
}

variable "whitelist_ip" {
  type = "list"
  description = "List of IPs to whitelist SSH from"
}

variable "num_pvt_subnets" {
  type = "string"
  description = "Number of private subnets to create for cluster nodes"
  default = "1"
}

variable "whitelist_outgoing" {
  default = ""
  description = "Public IP to whitelist outgoing traffic to."
}

output "bastion_ip" {
  value = "${module.bastion_node.public_ip}"
}

output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "private_subnet_id" {
  value = "${module.private_subnet.subnet_id}"
}

output "public_subnet_id" {
  value = "${module.public_subnet.subnet_id}"
}

output "vpc_endpoint" {
  value = ["${aws_vpc_endpoint.ec2.dns_entry}"]
}

