data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

resource "aws_network_acl" "public_subnet" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.public_subnet.id}"]

  tags = "${merge(
            map("name", "${var.prefix}-public-subnet-acl"),
            "${var.tags}"
          )}"
}

# SSH from Qubole
resource "aws_network_acl_rule" "ssh_in" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  egress = false
  count = "${length(var.whitelist_ip)}" 
  protocol   = "tcp"
  rule_number    = 101
  rule_action     = "allow"
  cidr_block = "${element(var.whitelist_ip, count.index)}"
  from_port  = 22
  to_port    = 22
}

# Response to SSH
resource "aws_network_acl_rule" "ssh_out" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  protocol   = "tcp"
  rule_number   = 101
  rule_action  = "allow"
  count = "${length(var.whitelist_ip)}" 
  cidr_block = "${element(var.whitelist_ip, count.index)}"
  from_port  = 32768
  to_port    = 65535
  egress = true
}

# HTTPS out
resource "aws_network_acl_rule" "https_out" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  protocol   = "tcp"
  rule_number   = 201
  rule_action  = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 443
  to_port    = 443
  egress = true
}

# HTTPS response
resource "aws_network_acl_rule" "https_in" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  protocol   = "tcp"
  rule_number   = 201
  rule_action  = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 32768
  to_port    = 65535
  egress = false
}

# Outgoing traffic within VPC
resource "aws_network_acl_rule" "vpc_out" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  protocol   = "tcp"
  rule_number   = 301
  rule_action  = "allow"
  cidr_block = "${data.aws_vpc.default.cidr_block}"
  from_port  = 0
  to_port    = 65535
  egress = true
}

# Incoming traffic within VPC
resource "aws_network_acl_rule" "vpc_in" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  protocol   = "tcp"
  rule_number   = 301
  rule_action  = "allow"
  cidr_block = "${data.aws_vpc.default.cidr_block}"
  from_port  = 0
  to_port    = 65535
  egress = false
}

# Internet gateway for the public subnet 
resource "aws_internet_gateway" "public_subnet" {
    vpc_id = "${var.vpc_id}"
}

# Route table for the public subnet
resource "aws_route_table" "public_subnet" {
    vpc_id = "${var.vpc_id}"

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
    vpc_id = "${var.vpc_id}"
    cidr_block = "${var.subnet_cidr}"
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
