variable "prefix" {
  type = "string"
  description = "Prefix for resource names"
}

variable "region" {
  type = "string"
  description = "Region to create the Lambda function in"
  default = "us-east-1"
}

variable "topic_arn" {
  type = "string"
  description = "ARN of the AMI update topic to subscribe to"
}