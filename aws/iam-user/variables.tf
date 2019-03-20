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

variable "user_name" {
  type = "string"
  description = "User name"
  default = "Qubole-user"
}

variable "s3location" {
  type = "string"
  description = "S3 location to save logs, outputs, etc"
}

output "user_name" {
  value = "${aws_iam_user.qubole_user.name}"
  description = "User name"
}

output "access_key_id" {
  value = "${aws_iam_access_key.qubole_user.id}"
  description = "Access Key Id"
}

output "secret_access_key" {
  value = "${aws_iam_access_key.qubole_user.secret}"
  description = "Secret Access Key"
}
