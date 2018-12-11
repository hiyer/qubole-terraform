# cidr block for the vpc
variable "cidr_block" {
  default = "10.0.0.0/16"
}

# prefix to apply for name tags
variable "prefix" {
  
}

# other tags to apply
variable "tags" {
  type = "map"

  default = {}
}

# aws region
variable "region" {
  default = "us-west-2"
}

# cidr for public subnet
variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

# Public IPs to whitelist SSH traffic from
# (either NAT or tunnel servers)
variable "whitelist_ip" {
  type = "list"
}

output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "public_subnet_id" {
  value = "${module.public_subnet.subnet_id}"
}






