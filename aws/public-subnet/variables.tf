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

# Public IP to whitelist SSH traffic from
# (either NAT or tunnel server)
variable "whitelist_ip" {
  
}

output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "public_subnet_id" {
  value = "${aws_subnet.public_subnet.id}"
}






