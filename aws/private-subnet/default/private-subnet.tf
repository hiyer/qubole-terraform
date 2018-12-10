# Configure the AWS provider
provider "aws" {
  region = "${var.region}"
}

module "public_subnet" {
  source = "../../modules/public_subnet"
  
  vpc_id = "${aws_vpc.default.id}"
  tags = "${var.tags}"
  prefix = "${var.prefix}"
  whitelist_ip = "${var.whitelist_ip}"
  subnet_cidr = "${var.public_subnet_cidr}"
}

module "bastion_node" {
  source = "../../modules/bastion_node"

  tags = "${var.tags}"
  prefix = "${var.prefix}"
  whitelist_ip = "${var.whitelist_ip}"
  aws_key_name = "${var.aws_key_name}"
  private_subnet_cidr = "${var.private_subnet_cidr}"
  public_subnet_id = "${module.public_subnet.subnet_id}"
  ssh_public_key = "${var.ssh_public_key}"
  vpc_id = "${aws_vpc.default.id}"
}

module "private_subnet" {
  source = "../../modules/private_subnet"
  
  vpc_id = "${aws_vpc.default.id}"
  tags = "${var.tags}"
  prefix = "${var.prefix}"
  whitelist_outgoing = "0.0.0.0/0"
  subnet_cidr = "${var.private_subnet_cidr}"
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
  route_table_ids = ["${module.public_subnet.route_table_id}"]
}

# Create NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  subnet_id = "${module.public_subnet.subnet_id}"
  allocation_id = "${aws_eip.nat_gateway.id}"

  tags = "${merge(
          map("name", "${var.prefix}-nat-gw"),
          "${var.tags}"
        )}"
}

# EIP for the NAT gateway
resource "aws_eip" "nat_gateway" {
  vpc = true

  tags = "${merge(
            map("name", "${var.prefix}-nat-eip"),
            "${var.tags}"
          )}"
}

# Route table entry for NAT gateway
resource "aws_route" "nat_gateway" {
  route_table_id = "${module.private_subnet.subnet_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
}



