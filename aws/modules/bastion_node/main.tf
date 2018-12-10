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

data "aws_vpc" "default" {
  id = "${var.vpc_id}"
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
      from_port = 32768
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["${var.private_subnet_cidr}"]
    }

    vpc_id = "${data.aws_vpc.default.id}"

    tags = "${merge(
            map("name", "${var.prefix}-bastion-sg"),
            "${var.tags}"
          )}"
}

# Bastion Instance
resource "aws_instance" "bastion_node" {
    ami = "${data.aws_ami.amzn_linux.id}"
    instance_type = "t3.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.bastion_node.id}"]
    subnet_id = "${var.public_subnet_id}"
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
resource "aws_eip" "bastion_node" {
    instance = "${aws_instance.bastion_node.id}"
    vpc = true
}

