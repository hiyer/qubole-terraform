variable "region" {
  type = "string"
  description = "Region to create the role/policy in"
  default = "us-west-2"
}

variable "account_id" {
  type = "string"
  description = "Account id"
}

variable "vpc_id" {
  type = "string"
  description = "VPC to restrict the compute resources to"
}

variable "role_name" {
  type = "string"
  description = "Role name"
  default = "Qubole access role"
}

variable "s3location" {
  type = "string"
  description = "S3 location to save logs, outputs, etc"
}

variable "qubole_account_id" {
  type = "string"
  description = "Qubole Trusted Account Id"
}

variable "qubole_external_id" {
  type = "string"
  description = "Qubole External Id"
}