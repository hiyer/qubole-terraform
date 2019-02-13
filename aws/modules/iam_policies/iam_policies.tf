provider "aws" {
  region = "${var.region}"
}

data "aws_iam_policy_document" "common_ec2_policy" {
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
}

resource "aws_iam_policy" "common_ec2_policy" {
  name = "${var.name_prefix}-access-policy"
  policy = "${data.aws_iam_policy_document.common_ec2_policy.json}"
}

data "aws_iam_policy_document" "s3_policy" {
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

resource "aws_iam_policy" "s3_policy" {
  name = "${var.name_prefix}-s3-policy"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}