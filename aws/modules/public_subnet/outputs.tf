output "subnet_id" {
  value = "${aws_subnet.public_subnet.*.id}"
  description = "Subnet id"
}

output "route_table_id" {
  value = "${aws_route_table.public_subnet.id}"
  description = "Route table id"
}

output "network_acl_id" {
  value = "${aws_network_acl.public_subnet.id}"
}