output "public_ip" {
  value = "${aws_eip.bastion_node.public_ip}"
}