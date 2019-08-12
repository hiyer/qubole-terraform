variable "vpc_id" {
  type        = string
  description = "Id of the VPC to create the network ACL in"
}

variable "ssh_whitelist_ip" {
  type        = list(string)
  description = "IP(s) to whitelist SSH from, if any"
  default     = []
}

variable "whitelist_outgoing" {
  type        = string
  description = "CIDR block to whitelist outgoing traffic to"
}

variable "allow_outgoing_http" {
  type        = bool
  description = "Whether to allow outgoing HTTP requests"
  default     = false
}

variable "prefix" {
  type        = string
  description = "Prefix for 'Name' tag"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets to apply the ACL to"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the Network ACL resource"
  default     = {}
}

variable "use_network_acls" {
  type        = bool
  description = "Whether to use Network ACLs. Included because terraform does not allow conditional inclusion of modules"
}
