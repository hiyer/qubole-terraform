output "access_policy_arn" {
  value = "${aws_iam_policy.access_policy.arn}"
}

output "s3_policy_arn" {
  value = "${aws_iam_policy.s3_policy.arn}"
}