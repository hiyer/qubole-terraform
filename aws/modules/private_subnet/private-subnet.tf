data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_availability_zones" "all" {
}

locals {
  newbits    = ceil(log(var.num_pvt_subnets + 1, 2))
  sorted_azs = sort(data.aws_availability_zones.all.names)
}

module "network_acl" {
  source = "../network_acl"

  vpc_id              = var.vpc_id
  tags                = var.tags
  prefix              = var.prefix
  whitelist_outgoing  = var.whitelist_outgoing
  allow_outgoing_http = "1"
  subnet_ids          = aws_subnet.private_subnet.*.id
  use_network_acls    = var.use_network_acls
}

/*
  Private Subnet
*/
resource "aws_subnet" "private_subnet" {
  count             = var.num_pvt_subnets
  vpc_id            = var.vpc_id
  availability_zone = element(local.sorted_azs, count.index)
  cidr_block = var.subnet_cidr != "" && var.num_pvt_subnets == 1 ? var.subnet_cidr : cidrsubnet(
    data.aws_vpc.default.cidr_block,
    local.newbits,
    count.index + 1,
  )
  tags = merge(
    {
      "Name" = "${var.prefix}-private-subnet-${element(local.sorted_azs, count.index)}"
    },
    var.tags,
  )
}

resource "aws_route_table" "private_subnet" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = "${var.prefix}-private-subnet-rt"
    },
    var.tags,
  )
}

resource "aws_route_table_association" "private_subnet" {
  count          = var.num_pvt_subnets
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_subnet.id
}

