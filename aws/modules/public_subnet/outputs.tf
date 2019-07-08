output "subnet_ids" {
  value       = aws_subnet.public_subnet.*.id
  description = "Subnet ids"
}

output "subnet_id" {
  value       = element(aws_subnet.public_subnet.*.id, 0)
  description = "Id of first subnet (for convenience)"
}

output "route_table_id" {
  value       = aws_route_table.public_subnet.id
  description = "Route table id"
}

