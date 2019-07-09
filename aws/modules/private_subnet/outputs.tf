output "subnet_ids" {
  value       = aws_subnet.private_subnet.*.id
  description = "Subnet id(s)"
}

output "subnet_id" {
  value       = element(aws_subnet.private_subnet.*.id, 0)
  description = "Id of the first subnet (convenience method)"
}

output "route_table_id" {
  value       = aws_route_table.private_subnet.id
  description = "Route table id"
}

