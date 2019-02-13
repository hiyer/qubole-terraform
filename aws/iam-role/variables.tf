variable "region" {
  type = "string"
  description = "Region of the vpc where compute resources will be provisioned"
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
  default = "Qubole-role"
}

variable "s3location" {
  type = "string"
  description = "S3 location to save logs, outputs, etc"
}

variable "qubole_account_id" {
  type = "string"
  description = "Qubole Trusted Account Id"
}

variable "qubole_external_ids" {
  type = "list"
  description = "Qubole External Id(s)"
}

output "role_arn" {
  value = "${aws_iam_role.qubole_role.arn}"
  description = "ARN of the role"
}

output "instance_profile_arn" {
  value = "${aws_iam_instance_profile.qubole_profile.arn}"
  description = "ARN of the instance profile"
}