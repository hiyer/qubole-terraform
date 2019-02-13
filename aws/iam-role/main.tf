provider "aws" {
  region = "${var.region}"
}

data "aws_iam_policy_document" "qubole_policy" {
  statement {
    sid = "NonResourceBasedPermissions",
    actions = [
      "ec2:AssociateAddress",
      "ec2:DisassociateAddress",
      "ec2:ImportKeyPair",
      "ec2:RequestSpotInstances",
      "ec2:RequestSpotFleet",
      "ec2:ModifySpotFleetRequest",
      "ec2:CancelSpotFleetRequests",
      "ec2:CancelSpotInstanceRequests",
      "ec2:CreateSpotDatafeedSubscription",
      "ec2:DeleteSpotDatafeedSubscription",
      "ec2:Describe*",
      "ec2:CreateKeyPair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "sts:DecodeAuthorizationMessage"
    ]
    resources = [
      "*"
    ]
  }

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
    condition {
      test = "StringEquals"
      variable = "ec2:InstanceProfile"
      values = ["arn:aws:iam::${var.account_id}:instance-profile/${aws_iam_role.qubole_role.name}"]
      }
    }

    statement {
      sid = "RunInstanceWithRole"
      actions = [
        "ec2:RunInstances",
        "ec2:CreateTags",
        "ec2:DeleteTags"
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

  statement {
    sid = "RunInstanceInSubnet"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:subnet/*"
    ]
    condition {
      test = "StringEquals"
      variable = "ec2:vpc"
      values = ["arn:aws:ec2:${var.region}:${var.account_id}:vpc/${var.vpc_id}"]
    }
  }
    
  statement {
    sid = "RunInstanceResourcePermissions"
    actions = [
      "ec2:RunInstances"
    ]
    resources = [
      "arn:aws:ec2:${var.region}::image/*",
      "arn:aws:ec2:${var.region}::snapshot/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:volume/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:network-interface/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:key-pair/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:security-group/*"
    ]
  }
    
  statement {
    sid = "SecurityGroupActions"
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = [
      "*"
    ]
    condition {
      test = "StringEquals"
      variable = "ec2:vpc"
      values = ["arn:aws:ec2:${var.region}:${var.account_id}:vpc/${var.vpc_id}"]
    }
  }

  statement {
    sid = "CreateAndDeleteVolumeActions"
    actions = [
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:volume/*"
    ]
  }
  
  statement {
    sid = "SpotFleet"
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:PutRolePolicy"
    ],
    resources = [
      "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
      "arn:aws:iam::*:role/aws-service-role/spotfleet.amazonaws.com/AWSServiceRoleForEC2SpotFleet"
    ]
    condition {
      test = "StringLike"
      variable =  "iam:AWSServiceName"
      values = [
          "spot.amazonaws.com",
          "spotfleet.amazonaws.com"
        ]
    }
  }
    
  statement {
    sid =  "DefaultLocationActions"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.s3location}/*",
      "arn:aws:s3:::${var.s3location}"
    ]
  }

  statement {
    sid =  "ListBucketsAndOthers"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ],
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "access_policy" {
  name = "${var.role_name}-access-policy"
  policy = "${data.aws_iam_policy_document.qubole_policy.json}"
}

resource "aws_iam_role_policy_attachment" "access_policy" {
  role = "${aws_iam_role.qubole_role.name}"
  policy_arn = "${aws_iam_policy.access_policy.arn}"
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
  name = "${var.role_name}-profile"
  role = "${aws_iam_role.qubole_role.name}"
}

