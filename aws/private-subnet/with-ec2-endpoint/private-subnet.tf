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

data "aws_availability_zones" "all" {
  
}

locals {
  num_pvt_subnets = "${var.num_pvt_subnets == 1 ? 1 : min(length(data.aws_availability_zones.all.names), var.num_pvt_subnets)}"
  num_subnets = "${local.num_pvt_subnets + 1}"  # One public subnet as well
  newbits = "${ceil(log(local.num_subnets, 2))}"
}

module "public_subnet" {
  source = "../../modules/public_subnet"
  
  vpc_id = "${aws_vpc.default.id}"
  tags = "${var.tags}"
  prefix = "${var.prefix}"
  whitelist_ip = "${var.whitelist_ip}"
  subnet_cidr = "${var.num_pvt_subnets == 1 && var.public_subnet_cidr != "" ? var.public_subnet_cidr : cidrsubnet(var.cidr_block, local.newbits, 0)}"
}

module "bastion_node" {
  source = "../../modules/bastion_node"

  tags = "${var.tags}"
  prefix = "${var.prefix}"
  whitelist_ip = "${var.whitelist_ip}"
  aws_key_name = "${var.aws_key_name}"
  public_subnet_id = "${module.public_subnet.subnet_id}"
  ssh_public_key = "${var.ssh_public_key}"
  vpc_id = "${aws_vpc.default.id}"
}

module "private_subnet" {
  source = "../../modules/private_subnet"
  
  vpc_id = "${aws_vpc.default.id}"
  tags = "${var.tags}"
  prefix = "${var.prefix}"
  whitelist_outgoing = "${var.whitelist_outgoing}"
  subnet_cidr = "${var.private_subnet_cidr}"
  num_pvt_subnets = "${var.num_pvt_subnets}"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = ["${module.private_subnet.route_table_id}"]
}

# Create ec2 endpoint
resource "aws_vpc_endpoint" "ec2" {
  vpc_id = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids = ["${module.private_subnet.subnet_id}"]
  private_dns_enabled = true
  security_group_ids = ["${aws_security_group.ec2_endpoint.id}"]
}

# Security group for the ec2 endpoint
resource "aws_security_group" "ec2_endpoint" {
  vpc_id = "${aws_vpc.default.id}"

  # Allow http from clusters
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${var.cidr_block}"]
  }

  # Allow https from clusters
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["${var.cidr_block}"]
  }
}

# Create NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  count = "${var.whitelist_outgoing != "" ? 1 : 0}"

  subnet_id = "${module.public_subnet.subnet_id}"
  allocation_id = "${aws_eip.nat_gateway.id}"
  tags = "${merge(
          map("name", "${var.prefix}-nat-gw"),
          "${var.tags}"
        )}"
}

# EIP for the NAT gateway
resource "aws_eip" "nat_gateway" {
  count = "${var.whitelist_outgoing != "" ? 1 : 0}"

  vpc = true
  tags = "${merge(
            map("name", "${var.prefix}-nat-eip"),
            "${var.tags}"
          )}"
}

# Route table entry for NAT gateway
resource "aws_route" "nat_gateway" {
  count = "${var.whitelist_outgoing != "" ? 1 : 0}"

  route_table_id = "${module.private_subnet.route_table_id}"
  destination_cidr_block = "${var.whitelist_outgoing}"
  nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
}


