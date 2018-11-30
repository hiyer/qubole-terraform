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
   
   # Allow response to SSH from Qubole NAT
   egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.whitelist_ip}"
    from_port  = 32768
    to_port    = 65535
  }

  # Allow HTTP
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # HTTPS
  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  
  # Allow SSH from Qubole NAT
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.whitelist_ip}"
    from_port  = 22
    to_port    = 22
  }

  # Allow inbound return traffic for hosts
  # on internet for traffic from this subnet
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
  tags = "${merge(
            map("name", "${var.prefix}-public-subnet-acl"),
            "${var.tags}"
          )}"
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
