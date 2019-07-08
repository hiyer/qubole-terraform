variable "account_id" {
  type        = string
  description = "Account Id"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "s3location" {
  type        = string
  description = "Default location on s3 to store logs, outputs, etc"
}

variable "name_prefix" {
  type        = string
  description = "Prefix to apply to policy names"
}

variable "vpc_id" {
  type        = string
  description = "VPC to restrict compute resources to"
}

