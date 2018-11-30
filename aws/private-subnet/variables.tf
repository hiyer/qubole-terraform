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

# Public IP to whitelist SSH traffic from
# (either NAT or tunnel server)
variable "whitelist_ip" {
  
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
  value = "${aws_subnet.public_subnet.id}"
}






