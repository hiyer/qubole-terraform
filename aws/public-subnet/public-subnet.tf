# Configure the AWS provider
provider "aws" {
  region = "${var.region}"
}

module "public_subnet" {
  source = "../modules/public_subnet"
  
  vpc_id = "${aws_vpc.default.id}"
  tags = "${var.tags}"
  prefix = "${var.prefix}"
  whitelist_ip = "${var.whitelist_ip}"
  subnet_cidr = "${var.public_subnet_cidr}"
  num_subnets = "${var.num_subnets}"
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