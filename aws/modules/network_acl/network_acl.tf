data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

resource "aws_network_acl" "default" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${var.subnet_ids}"]

  tags = "${merge(
            map("Name", "${var.prefix}-public-subnet-acl"),
            "${var.tags}"
          )}"
}

# SSH from Qubole
resource "aws_network_acl_rule" "ssh_in" {
  count = "${length(var.ssh_whitelist_ip)}"
  network_acl_id = "${aws_network_acl.default.id}"
  egress = false
  protocol   = "tcp"
  rule_number    = "${count.index + 101}"
  rule_action     = "allow"
  cidr_block = "${element(var.ssh_whitelist_ip, count.index)}"
  from_port  = 22
  to_port    = 22
}

# Response to SSH
resource "aws_network_acl_rule" "ssh_out" {
  rule_number   = "${count.index + 101}"
  network_acl_id = "${aws_network_acl.default.id}"
  protocol   = "tcp"
  rule_action  = "allow"
  count = "${length(var.ssh_whitelist_ip)}"
  cidr_block = "${element(var.ssh_whitelist_ip, count.index)}"
  from_port  = 1024
  to_port    = 65535
  egress = true
}

# HTTP out
resource "aws_network_acl_rule" "http_out" {
  count = "${var.whitelist_outgoing != "" && var.allow_outgoing_http != "0" ? 1 : 0}"
  network_acl_id = "${aws_network_acl.default.id}"
  egress = true
  protocol   = "tcp"
  rule_number    = 201
  rule_action     = "allow"
  cidr_block = "${var.whitelist_outgoing}"
  from_port  = 80
  to_port    = 80
}

# HTTPS out
resource "aws_network_acl_rule" "https_out" {
  count = "${var.whitelist_outgoing != "" ? 1 : 0}"
  network_acl_id = "${aws_network_acl.default.id}"
  protocol   = "tcp"
  rule_number   = 301
  rule_action  = "allow"
  cidr_block = "${var.whitelist_outgoing}"
  from_port  = 443
  to_port    = 443
  egress = true
}

# HTTP(S) response
resource "aws_network_acl_rule" "https_in" {
  count = "${var.whitelist_outgoing != "" ? 1 : 0}"
  network_acl_id = "${aws_network_acl.default.id}"
  protocol   = "tcp"
  rule_number   = 201
  rule_action  = "allow"
  cidr_block = "${var.whitelist_outgoing}"
  from_port  = 1024
  to_port    = 65535
  egress = false
}

# Outgoing traffic within VPC
resource "aws_network_acl_rule" "vpc_out" {
  network_acl_id = "${aws_network_acl.default.id}"
  protocol   = "tcp"
  rule_number   = 401
  rule_action  = "allow"
  cidr_block = "${data.aws_vpc.default.cidr_block}"
  from_port  = 0
  to_port    = 65535
  egress = true
}

# Incoming traffic within VPC
resource "aws_network_acl_rule" "vpc_in" {
  network_acl_id = "${aws_network_acl.default.id}"
  protocol   = "tcp"
  rule_number   = 401
  rule_action  = "allow"
  cidr_block = "${data.aws_vpc.default.cidr_block}"
  from_port  = 0
  to_port    = 65535
  egress = false
}