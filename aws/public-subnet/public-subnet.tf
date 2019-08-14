# Configure the AWS provider
provider "aws" {
  region  = var.region
  version = "~> 2.18.0"
}

module "public_subnet" {
  source = "../modules/public_subnet"

  vpc_id             = aws_vpc.default.id
  tags               = var.tags
  prefix             = var.prefix
  whitelist_ip       = var.whitelist_ip
  subnet_cidr        = var.public_subnet_cidr
  num_subnets        = var.num_subnets
  use_network_acls   = var.use_network_acls
  whitelist_outgoing = "0.0.0.0/0"
}

# Create a VPC
resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    {
      "name" = "${var.prefix}-vpc"
    },
    var.tags,
  )
}

# Create S3 endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.default.id
  service_name = "com.amazonaws.${var.region}.s3"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  route_table_ids = [module.public_subnet.route_table_id]
}

