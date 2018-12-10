variable "tags" {
  type = "map"
  description = "Map of tags to attach to security group and instance"
}

variable "aws_key_name" {
  type = "string"
  description = "SSH key pair to bring up the instance"
}

variable "whitelist_ip" {
  type = "list"
  description = "List of IPs to whitelist SSH from"
}

variable "prefix" {
  type = "string"
  description = "Prefix for 'name' tag"
}

variable "private_subnet_cidr" {
  type = "string"
  description = "CIDR specification for the *private* subnet, to allow reverse tunnel traffic"
}

variable "public_subnet_id" {
  type = "string"
  description = "Id of the public subnet in which to create the bastion node"
}

variable "ssh_public_key" {
  type = "string"
  description = "SSH public key for SSH'ing into your bastion node. This is the Account key in the cluster details page"
}

variable "vpc_id" {
  type = "string"
  description = "Id of the VPC to bring up the instance in"
}