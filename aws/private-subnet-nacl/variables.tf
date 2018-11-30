# vpc cidr block
variable "cidr_block" {
  default = "10.0.0.0/16"
}

# key pair to use for bastion node
variable "aws_key_name" {
  
}

# private subnet cidr
variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

# prefix to use for name tags
variable "prefix" {
  
}

# other tags
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

# cidr for bastion node subnet. Keep this small
variable "bastion_subnet_cidr" {
  default = "10.0.2.0/28"
}

# cidr for public subnet
variable "nat_subnet_cidr" {
  default = "10.0.0.0/24"
}

output "bastion_ip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "private_subnet_id" {
  value = "${aws_subnet.private_subnet.id}"
}

output "public_subnet_id" {
  value = "${aws_subnet.nat_subnet.id}"
}

# Public IP to whitelist SSH traffic from
# (either NAT or tunnel server)
variable "whitelist_ip" {
}