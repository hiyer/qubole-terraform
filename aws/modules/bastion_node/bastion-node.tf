data "aws_ami" "amzn_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
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

# Security group for the Bastion node
resource "aws_security_group" "bastion_node" {
  name        = "${var.prefix}_bastion_sg"
  description = "Bastion node for access from qubole hosts"

  # Allow ssh from Qubole NAT
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ip
  }

  # Allow port 7000 from clusters (metastore)
  ingress {
    from_port   = 7000
    to_port     = 7000
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  # Allow all outgoing traffic to private subnet
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
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
  ami                         = data.aws_ami.amzn_linux.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = [aws_security_group.bastion_node.id]
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
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

