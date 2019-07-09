data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_availability_zones" "all" {
}

locals {
  num_subnets = min(
    length(data.aws_availability_zones.all.names),
    var.num_subnets,
  )
  newbits    = ceil(log(local.num_subnets, 2))
  sorted_azs = sort(data.aws_availability_zones.all.names)
}

module "network_acl" {
  source = "../network_acl"

  vpc_id              = var.vpc_id
  tags                = var.tags
  prefix              = var.prefix
  whitelist_outgoing  = "0.0.0.0/0"
  ssh_whitelist_ip    = var.whitelist_ip
  allow_outgoing_http = "1"
  subnet_ids          = aws_subnet.public_subnet.*.id
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "public_subnet" {
  vpc_id = var.vpc_id
  tags = merge(
    {
      "Name" = "${var.prefix}-internet-gateway"
    },
    var.tags,
  )
}

# Route table for the public subnet
resource "aws_route_table" "public_subnet" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_subnet.id
  }

  tags = merge(
    {
      "Name" = "${var.prefix}-public-subnet-rt"
    },
    var.tags,
  )
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  count = local.num_subnets

  vpc_id            = var.vpc_id
  availability_zone = element(local.sorted_azs, count.index)
  cidr_block        = var.subnet_cidr != "" && local.num_subnets == 1 ? var.subnet_cidr : cidrsubnet(data.aws_vpc.default.cidr_block, local.newbits, count.index)
  tags = merge(
    {
      "Name" = "${var.prefix}-public-subnet-${element(local.sorted_azs, count.index)}"
    },
    var.tags,
  )
}

# Route table association
resource "aws_route_table_association" "public_subnet" {
  count          = local.num_subnets
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_subnet.id
}

