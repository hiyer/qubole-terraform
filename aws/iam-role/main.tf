provider "aws" {
  region = "${var.region}"
}

module "iam" {
  source = "../modules/iam"

  region = "${var.region}"
  account_id = "${var.account_id}"
  s3location = "${var.s3location}"
  name_prefix = "${var.role_name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_iam_role_policy_attachment" "access_policy" {
  role = "${aws_iam_role.qubole_role.name}"
  policy_arn = "${module.iam.ec2_policy_arn}"
}

data "aws_iam_policy_document" "instance_profile_policy" {
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
      "ec2:DeleteTags",
      "ec2:RunInstances"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:instance/*"
    ]
    condition {
      test = "StringEquals"
      variable = "ec2:InstanceProfile"
      values = ["arn:aws:iam::${var.account_id}:instance-profile/${aws_iam_role.qubole_role.name}"]
    }
  }
}

resource "aws_iam_policy" "instance_profile_policy" {
  name = "${var.role_name}-profile-policy"
  policy = "${data.aws_iam_policy_document.instance_profile_policy.json}"
}

resource "aws_iam_role_policy_attachment" "instance_profile_policy" {
  role = "${aws_iam_role.qubole_role.name}"
  policy_arn = "${aws_iam_policy.instance_profile_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role = "${aws_iam_role.qubole_role.name}"
  policy_arn = "${module.iam.s3_policy_arn}"
}

data "aws_iam_policy_document" "cross_account_policy" {
  statement {
    actions = ["iam:GetInstanceProfile"]
    resources = ["arn:aws:iam::${var.account_id}:instance-profile/${var.role_name}-profile"]
  }

  statement {
    actions = ["iam:PassRole"]
    resources = ["arn:aws:iam::${var.account_id}:role/${var.role_name}"]
  }
}

resource "aws_iam_policy" "cross_account_policy" {
  name = "${var.role_name}-cross-account-policy"
  policy = "${data.aws_iam_policy_document.cross_account_policy.json}"
}

resource "aws_iam_role_policy_attachment" "cross_account_policy" {
  role = "${aws_iam_role.qubole_role.name}"
  policy_arn = "${aws_iam_policy.cross_account_policy.arn}"
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
  statement {
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.qubole_account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "${var.qubole_external_ids}"
      ]
    }
  }
}

resource "aws_iam_role" "qubole_role" {
  name = "${var.role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.trust_policy.json}"
}

resource "aws_iam_instance_profile" "qubole_profile" {
  name = "${var.role_name}"
  role = "${aws_iam_role.qubole_role.name}"
}

