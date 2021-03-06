variable "region" {
  type        = string
  description = "Region of the vpc where compute resources will be provisioned"
  default     = "us-west-2"
}

variable "account_id" {
  type        = string
  description = "Account id"
}

variable "vpc_ids" {
  type        = list(map(string))
  description = "VPCs to restrict the compute resources to"
}

variable "role_name" {
  type        = string
  description = "Role name"
  default     = "Qubole-role"
}

variable "s3location" {
  type        = string
  description = "S3 location to save logs, outputs, etc"
}

variable "qubole_external_ids" {
  type        = list(string)
  description = "Qubole External Id(s)"
}

variable "qubole_account_ids" {
  type        = list(string)
  description = "Qubole Account Id(s)"
}

output "role_arn" {
  value       = aws_iam_role.qubole_role.arn
  description = "ARN of the role"
}

output "instance_profile_arn" {
  value       = aws_iam_instance_profile.qubole_profile.arn
  description = "ARN of the instance profile"
}

