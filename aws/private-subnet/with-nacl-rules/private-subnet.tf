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
  route_table_ids = ["${aws_route_table.nat_subnet.id}"]
}

resource "aws_network_acl" "bastion_subnet" {
  vpc_id = "${aws_vpc.default.id}"
  subnet_ids = ["${aws_subnet.bastion_subnet.id}"]
   
   # Allow response to SSH from Qubole NAT
   egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.whitelist_ip}"
    from_port  = 32768
    to_port    = 65535
  }
  
  # Allow all traffic from within VPC
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "${var.cidr_block}"
    from_port  = 0
    to_port    = 65535
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
  
  # Allow all traffic from within VPC
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "${var.cidr_block}"
    from_port  = 0
    to_port    = 65535
  }

  tags = "${merge(
            map("name", "${var.prefix}-bastion-subnet-acl"),
            "${var.tags}"
          )}"
}

resource "aws_network_acl" "nat_subnet" {
  vpc_id = "${aws_vpc.default.id}"
  subnet_ids = ["${aws_subnet.nat_subnet.id}"]

  # Allow HTTP
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # HTTPS
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

    # Allow all traffic from within VPC
   egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "${var.cidr_block}"
    from_port  = 0
    to_port    = 65535
  }

  # Allow inbound return traffic for hosts
  # on internet for traffic originating in
  # private subnet
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow all traffic from within VPC
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.cidr_block}"
    from_port  = 0
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

# Route table for the nat public subnet
resource "aws_route_table" "nat_subnet" {
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

resource "aws_route_table" "bastion_subnet" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.public_subnet.id}"
    }

    tags = "${merge(
            map("name", "${var.prefix}-bastion-subnet-rt"),
            "${var.tags}"
          )}"
}

# NAT subnet
resource "aws_subnet" "nat_subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.nat_subnet_cidr}"
    tags = "${merge(
            map("name", "${var.prefix}-public-subnet"),
            "${var.tags}"
          )}"
}

# Bastion subnet
resource "aws_subnet" "bastion_subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.bastion_subnet_cidr}"
    tags = "${merge(
            map("name", "${var.prefix}-bastion-subnet"),
            "${var.tags}"
          )}"
}

# Route table association
resource "aws_route_table_association" "nat_subnet" {
    subnet_id = "${aws_subnet.nat_subnet.id}"
    route_table_id = "${aws_route_table.nat_subnet.id}"
}

resource "aws_route_table_association" "bastion_subnet" {
    subnet_id = "${aws_subnet.bastion_subnet.id}"
    route_table_id = "${aws_route_table.bastion_subnet.id}"
}

/*
  NAT Gateway
*/
resource "aws_eip" "nat" {
  vpc = true
  depends_on = ["aws_subnet.nat_subnet"]
}

resource "aws_nat_gateway" "nat_gateway" {
    subnet_id = "${aws_subnet.nat_subnet.id}"
    allocation_id = "${aws_eip.nat.id}"
    depends_on = ["aws_internet_gateway.public_subnet"]

    tags = "${merge(
            map("name", "${var.prefix}-nat-gw"),
            "${var.tags}"
          )}"
}

# Security group for the Bastion node
resource "aws_security_group" "bastion_sg" {
    name = "bastion_sg"
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

resource "aws_instance" "bastion_instance" {
    ami = "ami-0d441475"
    instance_type = "t2.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}"]
    subnet_id = "${aws_subnet.bastion_subnet.id}"
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
                EOF

    tags = "${merge(
            map("name", "${var.prefix}-bastion"),
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

  # Allow HTTP
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # HTTPS
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
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
  
  # Inbound return traffic for external HTTP(s) calls
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
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

# Send all internet traffic through the NAT
resource "aws_route_table" "private_subnet" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
    }

    tags = "${merge(
            map("name", "${var.prefix}-private-subnet-rt"),
            "${var.tags}"
          )}"
}

resource "aws_route_table_association" "private_subnet" {
    subnet_id = "${aws_subnet.private_subnet.id}"
    route_table_id = "${aws_route_table.private_subnet.id}"
}

