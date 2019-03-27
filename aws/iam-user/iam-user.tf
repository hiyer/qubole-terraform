provider "aws" {
  region = "${var.region}"
}

resource "aws_iam_user" "qubole_user" {
  name = "${var.user_name}"
}

resource "aws_iam_access_key" "qubole_user" {
  user = "${aws_iam_user.qubole_user.name}"
}

module "iam" {
  source = "../modules/iam"

  region = "${var.region}"
  account_id = "${var.account_id}"
  s3location = "${var.s3location}"
  name_prefix = "${var.user_name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_iam_user_policy_attachment" "access_policy" {
  user = "${aws_iam_user.qubole_user.name}"
  policy_arn = "${module.iam.ec2_policy_arn}"
}

resource "aws_iam_user_policy_attachment" "s3_policy" {
  user = "${aws_iam_user.qubole_user.name}"
  policy_arn = "${module.iam.s3_policy_arn}"
}

data "aws_iam_policy_document" "instance_policy" {
  statement {
    sid = "AllowInstanceActions"
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:ModifyInstanceAttribute",
      "ec2:TerminateInstances",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:instance/*"
    ]
  }
}

resource "aws_iam_policy" "instance_policy" {
  name = "${var.user_name}-instance-policy"
  policy = "${data.aws_iam_policy_document.instance_policy.json}"
}

resource "aws_iam_user_policy_attachment" "instance_policy" {
  user = "${aws_iam_user.qubole_user.name}"
  policy_arn = "${aws_iam_policy.instance_policy.arn}"
}
