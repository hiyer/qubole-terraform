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
  route_table_ids = ["${aws_route_table.private_subnet.id}"]
}

# Create ec2 endpoint
resource "aws_vpc_endpoint" "ec2" {
  vpc_id = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids = ["${aws_subnet.private_subnet.id}"]
  private_dns_enabled = true
  security_group_ids = ["${aws_vpc.default.default_security_group_id}"]
}

resource "aws_network_acl" "public_subnet" {
  vpc_id = "${aws_vpc.default.id}"
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
  rule_number    = 100
  rule_action     = "allow"
  cidr_block = "${element(var.whitelist_ip, count.index)}"
  from_port  = 22
  to_port    = 22
}

# Response to SSH
resource "aws_network_acl_rule" "ssh_out" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  protocol   = "tcp"
  rule_number   = 100
  rule_action  = "allow"
  count = "${length(var.whitelist_ip)}" 
  cidr_block = "${element(var.whitelist_ip, count.index)}"
  from_port  = 32768
  to_port    = 65535
  egress = true
}

# Outgoing traffic within VPC
resource "aws_network_acl_rule" "vpc_out" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  protocol   = "tcp"
  rule_number   = 200
  rule_action  = "allow"
  cidr_block = "${var.cidr_block}"
  from_port  = 0
  to_port    = 65535
  egress = true
}

# Incoming traffic within VPC
resource "aws_network_acl_rule" "vpc_in" {
  network_acl_id = "${aws_network_acl.public_subnet.id}"
  protocol   = "tcp"
  rule_number   = 200
  rule_action  = "allow"
  cidr_block = "${var.cidr_block}"
  from_port  = 0
  to_port    = 65535
  egress = false
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

data "aws_ami" "amzn_linux" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "is-public"
    values = ["true"]
  }
  owners = ["amazon"]
}

# Security group for the Bastion node
resource "aws_security_group" "bastion_sg" {
    name = "${var.prefix}_bastion_sg"
    description = "Bastion node for access from qubole hosts"

    # Allow ssh from Qubole NAT
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.whitelist_ip}"]
    }

    # Allow port 7000 from clusters (metastore)
    ingress {
        from_port = 7000
        to_port = 7000
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    
    # Allow outgoing traffic to private subnet
    egress {
      from_port = 0
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["${var.private_subnet_cidr}"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags = "${merge(
            map("name", "${var.prefix}-bastion-sg"),
            "${var.tags}"
          )}"
}

# Bastion Instance
resource "aws_instance" "bastion_instance" {
    ami = "${data.aws_ami.amzn_linux.id}"
    instance_type = "t2.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}"]
    subnet_id = "${aws_subnet.public_subnet.id}"
    associate_public_ip_address = true
    root_block_device {
      volume_size = 20
      volume_type = "gp2"
      delete_on_termination = true
    }
    user_data = <<-EOF
                #!/bin/bash
                echo ${var.ssh_public_key} >> /home/ec2-user/.ssh/authorized_keys
                echo ${var.ssh_public_key} >> /home/root/.ssh/authorized_keys
                if grep -q "^GatewayPorts no" /etc/ssh/sshd_config; then
                  sed -i 's/GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config
                elif grep -q "^GatewayPorts yes" /etc/ssh/sshd_config; then
                  echo "GatewayPorts already enabled."
                else
                  echo "GatewayPorts yes >> /etc/ssh/sshd_config"
                fi
                systemctl restart ssh || /etc/init.d/sshd restart
                EOF

    tags = "${merge(
            map("name", "${var.prefix}-bastion-instance"),
            "${var.tags}"
          )}"
}

# Enable EIP for the Bastion Host
resource "aws_eip" "bastion" {
    instance = "${aws_instance.bastion_instance.id}"
    vpc = true
}

resource "aws_network_acl" "private_subnet" {
  vpc_id = "${aws_vpc.default.id}"
  subnet_ids = ["${aws_subnet.private_subnet.id}"]

  # Allow outbound responses to vpc
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.cidr_block}"
    from_port  = 0
    to_port    = 65535
  }
  
  # Inbound traffic from VPC
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.cidr_block}"
    from_port  = 0
    to_port    = 65535
  }

  tags = "${merge(
            map("name", "${var.prefix}-private-subnet-acl"),
            "${var.tags}"
          )}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "private_subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.private_subnet_cidr}"
    tags = "${merge(
            map("name", "${var.prefix}-private-subnet"),
            "${var.tags}"
          )}"
}

# No entries in the route table as such. This is only
# required to attach the s3 endpoint
resource "aws_route_table" "private_subnet" {
    vpc_id = "${aws_vpc.default.id}"

    tags = "${merge(
            map("name", "${var.prefix}-private-subnet-rt"),
            "${var.tags}"
          )}"
}

resource "aws_route_table_association" "private_subnet" {
    subnet_id = "${aws_subnet.private_subnet.id}"
    route_table_id = "${aws_route_table.private_subnet.id}"
}


