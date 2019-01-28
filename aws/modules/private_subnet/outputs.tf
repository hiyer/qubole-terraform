output "subnet_id" {
  value = "${aws_subnet.private_subnet.*.id}"
}

output "route_table_id" {
  value = "${aws_route_table.private_subnet.id}"
}
