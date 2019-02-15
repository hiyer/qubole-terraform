data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

data "aws_availability_zones" "all" {
  
}

locals {
  num_subnets = "${min(length(data.aws_availability_zones.all.names), var.num_subnets)}"
  newbits = "${ceil(log(local.num_subnets, 2))}"
  sorted_azs = "${sort(data.aws_availability_zones.all.names)}"
}


resource "aws_network_acl" "public_subnet" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.public_subnet.*.id}"]

  tags = "${merge(
            map("Name", "${var.prefix}-public-subnet-acl"),
            "${var.tags}"
          )}"
}

# SSH from Qubole
resource "aws_network_acl_rule" "ssh_in" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  egress = false
  count = "${length(var.whitelist_ip)}" 
  protocol   = "tcp"
  rule_number    = "${count.index + 101}"
  rule_action     = "allow"
  cidr_block = "${element(var.whitelist_ip, count.index)}"
  from_port  = 22
  to_port    = 22
}

# Response to SSH
resource "aws_network_acl_rule" "ssh_out" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  protocol   = "tcp"
  rule_number   = "${count.index + 101}"
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
            map("Name", "${var.prefix}-public-subnet-rt"),
            "${var.tags}"
          )}"
}

# Public subnet
resource "aws_subnet" "public_subnet" {
    count = "${local.num_subnets}"

    vpc_id = "${var.vpc_id}"
    availability_zone = "${element(local.sorted_azs, count.index)}"
    cidr_block = "${var.subnet_cidr != "" && local.num_subnets == 1 ? var.subnet_cidr : cidrsubnet(data.aws_vpc.default.cidr_block, local.newbits, count.index)}"
    tags = "${merge(
            map("Name", "${var.prefix}-public-subnet-${element(local.sorted_azs, count.index)}"),
            "${var.tags}"
          )}"
}

# Route table association
resource "aws_route_table_association" "public_subnet" {
    count = "${local.num_subnets}"
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.public_subnet.id}"
}
