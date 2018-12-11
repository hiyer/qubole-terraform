output "subnet_id" {
  value = "${aws_subnet.public_subnet.id}"
}

output "route_table_id" {
  value = "${aws_route_table.public_subnet.id}"
}