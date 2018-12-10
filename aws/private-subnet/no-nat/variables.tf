# cidr block for the vpc
variable "cidr_block" {
  default = "10.0.0.0/16"
}

# Key pair to use for bastion node
variable "aws_key_name" {
  
}

# prefix to apply for name tags
variable "prefix" {
  
}

# other tags to apply
variable "tags" {
  type = "map"

  default = {}
}

# public key to use for bastion node. This is the
# "account key" in cluster UI
variable "ssh_public_key" {
  
}

# aws region
variable "region" {
  default = "us-west-2"
}

# cidr for public subnet
variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

# cidr for private subnet
variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

# Public IPs to whitelist SSH traffic from
# (either NAT or tunnel servers)
variable "whitelist_ip" {
  type = "list"
}

# Public IPs of Qubole to whitelist
# HTTPS traffic to/from
variable "whitelist_outgoing" {
  default = ""
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

