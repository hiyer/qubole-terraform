output "ec2_policy_arn" {
  value = "${aws_iam_policy.common_ec2_policy.arn}"
}

output "s3_policy_arn" {
  value = "${aws_iam_policy.s3_policy.arn}"
}