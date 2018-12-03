# Configure the AWS provider
provider "aws" {
  region = "${var.region}"
}

# Create a VPC
resource "aws_vpc" "default" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = "${merge(
            map("name", "${var.prefix}-vpc"),
            "${var.tags}"
          )}"
}

# Create S3 endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = ["${aws_route_table.public_subnet.id}"]
}

resource "aws_network_acl" "public_subnet" {
  vpc_id = "${aws_vpc.default.id}"
  subnet_ids = ["${aws_subnet.public_subnet.id}"]
   
  tags = "${merge(
            map("name", "${var.prefix}-public-subnet-acl"),
            "${var.tags}"
          )}"
}

# SSH response egress
resource "aws_network_acl_rule" "ssh_out" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  egress = true
  count = "${length(var.whitelist_ip)}" 
  protocol     = "tcp"
  rule_action = "allow"
  rule_number  = 100
  cidr_block   = "${element(var.whitelist_ip, count.index)}"
  from_port    = 32768
  to_port      = 65535
}

# SSH ingress
resource "aws_network_acl_rule" "ssh_in" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  egress = false
  count = "${length(var.whitelist_ip)}" 
  protocol     = "tcp"
  rule_action = "allow"
  rule_number  = 100
  cidr_block   = "${element(var.whitelist_ip, count.index)}"
  from_port    = 22
  to_port      = 22
}

# HTTP egress
resource "aws_network_acl_rule" "http_out" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  egress = true
  protocol     = "tcp"
  rule_action = "allow"
  rule_number  = 200
  cidr_block   = "0.0.0.0/0"
  from_port    = 80
  to_port      = 80
}

# HTTPS egress
resource "aws_network_acl_rule" "https_out" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  egress = true
  protocol     = "tcp"
  rule_action = "allow"
  rule_number  = 300
  cidr_block   = "0.0.0.0/0"
  from_port    = 443
  to_port      = 443
}

# HTTP(s) response
resource "aws_network_acl_rule" "https_in" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  egress = false
  protocol     = "tcp"
  rule_action = "allow"
  rule_number  = 200
  cidr_block   = "0.0.0.0/0"
  from_port    = 1024
  to_port      = 65535
}

# Internet gateway for the public subnet 
resource "aws_internet_gateway" "public_subnet" {
    vpc_id = "${aws_vpc.default.id}"
}

# Route table for the public subnet
resource "aws_route_table" "public_subnet" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.public_subnet.id}"
    }

    tags = "${merge(
            map("name", "${var.prefix}-public-subnet-rt"),
            "${var.tags}"
          )}"
}

# Public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet_cidr}"
    tags = "${merge(
            map("name", "${var.prefix}-public-subnet"),
            "${var.tags}"
          )}"
}

# Route table association
resource "aws_route_table_association" "public_subnet" {
    subnet_id = "${aws_subnet.public_subnet.id}"
    route_table_id = "${aws_route_table.public_subnet.id}"
}
