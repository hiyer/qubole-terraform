output "public_ip" {
  value       = aws_eip.bastion_node.public_ip
  description = "IP address of the bastion node"
}

output "instance_id" {
  value       = aws_instance.bastion_node.id
  description = "Instance Id of the bastion node"
}

