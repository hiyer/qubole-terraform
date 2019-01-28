data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

data "aws_availability_zones" "all" {
  
}

locals {
  num_subnets = "${var.subnet_cidr != "" ? 1 : min(length(data.aws_availability_zones.all.names), var.num_pvt_subnets)}"
  newbits = "${ceil(log(local.num_subnets, 2))}"
}

resource "aws_network_acl" "private_subnet" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.private_subnet.*.id}"]

  tags = "${merge(
            map("name", "${var.prefix}-private-subnet-acl"),
            "${var.tags}"
          )}"
}

# VPC in
resource "aws_network_acl_rule" "vpc_in" {
  network_acl_id = "${aws_network_acl.private_subnet.id}"
  egress = false
  protocol   = "tcp"
  rule_number    = 100
  rule_action     = "allow"
  cidr_block = "${data.aws_vpc.default.cidr_block}"
  from_port  = 0
  to_port    = 65535
}

# VPC out
resource "aws_network_acl_rule" "vpc_out" {
  network_acl_id = "${aws_network_acl.private_subnet.id}"
  egress = true
  protocol   = "tcp"
  rule_number    = 100
  rule_action     = "allow"
  cidr_block = "${data.aws_vpc.default.cidr_block}"
  from_port  = 0
  to_port    = 65535
}

# HTTP out
resource "aws_network_acl_rule" "http_out" {
  count = "${var.whitelist_outgoing != "" ? 1 : 0}"
  network_acl_id = "${aws_network_acl.private_subnet.id}"
  egress = true
  protocol   = "tcp"
  rule_number    = 200
  rule_action     = "allow"
  cidr_block = "${var.whitelist_outgoing}"
  from_port  = 80
  to_port    = 80
}

# HTTPs out
resource "aws_network_acl_rule" "https_out" {
  count = "${var.whitelist_outgoing != "" ? 1 : 0}"
  network_acl_id = "${aws_network_acl.private_subnet.id}"
  egress = true
  protocol   = "tcp"
  rule_number    = 300
  rule_action     = "allow"
  cidr_block = "${var.whitelist_outgoing}"
  from_port  = 443
  to_port    = 443
}

# HTTP(s) response
resource "aws_network_acl_rule" "https_in" {
  count = "${var.whitelist_outgoing != "" ? 1 : 0}"
  network_acl_id = "${aws_network_acl.private_subnet.id}"
  egress = false
  protocol   = "tcp"
  rule_number    = 200
  rule_action     = "allow"
  cidr_block = "${var.whitelist_outgoing}"
  from_port  = 1024
  to_port    = 65535
}

/*
  Private Subnet
*/
resource "aws_subnet" "private_subnet" {
  count = "${local.num_subnets}"
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.subnet_cidr != "" ? var.subnet_cidr : cidrsubnet(data.aws_vpc.default.cidr_block, local.newbits, count.index)}"
  tags = "${merge(
          map("name", "${var.prefix}-private-subnet-${element(data.aws_availability_zones.all.names, count.index)}"),
          "${var.tags}"
        )}"
}

resource "aws_route_table" "private_subnet" {
  vpc_id = "${var.vpc_id}"

  tags = "${merge(
          map("name", "${var.prefix}-private-subnet-rt"),
          "${var.tags}"
        )}"
}

resource "aws_route_table_association" "private_subnet" {
    count = "${local.num_subnets}"
    subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.private_subnet.id}"
}
