data "aws_ami" "amzn_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "is-public"
    values = ["true"]
  }
  owners = ["amazon"]
}

data "aws_vpc" "default" {
  id = var.vpc_id
}

# Create ssm endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  subnet_ids          = [var.public_subnet_id]
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ssm_endpoint.id]
}

# Create ssm endpoint
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  subnet_ids          = [var.public_subnet_id]
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ssm_endpoint.id]
}

# Security group for the ec2 endpoint
resource "aws_security_group" "ssm_endpoint" {
  vpc_id = data.aws_vpc.default.id

  # Allow http from clusters
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  # Allow https from clusters
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }
}

resource "aws_iam_role" "bastion_node" {
  name = "${var.prefix}-bastion-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    {
      "Name" = "${var.prefix}-bastion-role"
    },
    var.tags,
  )
}

resource "aws_iam_role_policy_attachment" "bastion_node" {
  role = aws_iam_role.bastion_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_node" {
  name = "${var.prefix}-bastion-instance-profile"
  role = aws_iam_role.bastion_node.name
}

# Security group for the Bastion node
resource "aws_security_group" "bastion_node" {
  name = "${var.prefix}_bastion_sg"
  description = "Bastion node for access from qubole hosts"

  # Allow ssh from Qubole NAT
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.whitelist_ip
  }

  # Allow port 7000 from clusters (metastore)
  ingress {
    from_port = 7000
    to_port = 7000
    protocol = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  # Allow all outgoing traffic to private subnet
  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = "${var.prefix}-bastion-sg"
    },
    var.tags,
  )
}

# Bastion Instance
resource "aws_instance" "bastion_node" {
  ami = data.aws_ami.amzn_linux.id
  instance_type = var.instance_type
  key_name = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.bastion_node.id]
  subnet_id = var.public_subnet_id
  iam_instance_profile = aws_iam_instance_profile.bastion_node.name

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
                fields=(GatewayPorts AllowTcpForwarding)
                for f in "$${fields[@]}"; do
                  sed -i "/$${f}/d" /etc/ssh/sshd_config
                  echo "$${f} yes" >> /etc/ssh/sshd_config
                done
                systemctl restart ssh || /etc/init.d/sshd restart
EOF


  tags = merge(
    {
      "Name" = "${var.prefix}-bastion-instance"
    },
    var.tags,
  )
}

# Enable EIP for the Bastion Host
resource "aws_eip" "bastion_node" {
  instance = aws_instance.bastion_node.id
  vpc      = true
}

