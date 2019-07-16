provider "aws" {
  region  = var.region
  version = "~> 2.18.0"
}

data "aws_iam_policy_document" "common_ec2_policy" {
  # These permissions don't have any associated resources, or are
  # required on multiple resources and hence collated here
  statement {
    sid = "NonResourceBasedPermissions"
    actions = [
      "ec2:AssociateAddress",
      "ec2:DisassociateAddress",
      "ec2:ImportKeyPair",
      "ec2:RequestSpotInstances",
      "ec2:RequestSpotFleet",
      "ec2:ModifySpotFleetRequest",
      "ec2:CancelSpotFleetRequests",
      "ec2:CancelSpotInstanceRequests",
      "ec2:Describe*",
      "ec2:CreateKeyPair",
      "ec2:CreateSecurityGroup",
      "ec2:ModifySecurityGroup",
      "ec2:CreateTags",
      "sts:DecodeAuthorizationMessage",
    ]
    resources = [
      "*",
    ]
  }

  # Permit bringing up instances in subnets of a specific VPC only
  statement {
    sid = "RunInstanceInSubnet"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:subnet/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:vpc"
      values   = [
                  for vpc in var.vpc_ids:
                  "arn:aws:ec2:${var.region}:${vpc.account_id}:vpc/${vpc.vpc_id}"
                 ]
                   
    }
  }

  # Permissions required on various resources to bring up an instance
  statement {
    sid = "RunInstanceResourcePermissions"
    actions = [
      "ec2:RunInstances",
    ]
    resources = [
      "arn:aws:ec2:${var.region}::image/*",
      "arn:aws:ec2:${var.region}::snapshot/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:volume/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:network-interface/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:key-pair/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:security-group/*",
    ]
  }

  # Permissions required on the security group that Qubole
  # creates for each cluster
  statement {
    sid = "SecurityGroupActions"
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:vpc"
      values   = [
                  for vpc in var.vpc_ids:
                  "arn:aws:ec2:${var.region}:${vpc.account_id}:vpc/${vpc.vpc_id}"
                 ]
    }
  }

  # Required for EBS-based storage upscaling
  statement {
    sid = "CreateAndDeleteVolumeActions"
    actions = [
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:volume/*",
    ]
  }

  # Required for heterogeneous clusters
  statement {
    sid = "GetRole"
    actions = [
      "iam:GetRole",
    ]
    resources = ["*"]
    # Use below if you want to allow only for the spot fleet role
    # resources = [
    #   "arn:aws:iam::${var.account_id}:role/qubole-ec2-spot-fleet-role"
    # ]
  }
}

data "aws_iam_policy_document" "spot_fleet_assume_role" {
  statement {
    sid     = "SpotFleetAssumeRole"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "spot_fleet_service_role" {
  statement {
    actions = [
      "ec2:DescribeImages",
      "ec2:DescribeSubnets",
      "ec2:RequestSpotInstances",
      "ec2:TerminateInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:CreateTags",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = ["iam:PassRole"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "ec2.amazonaws.com",
        "ec2.amazonaws.com.cn",
      ]
    }
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "spot_fleet_service_role" {
  name   = "${var.name_prefix}-spot-fleet-service-policy"
  policy = data.aws_iam_policy_document.spot_fleet_service_role.json
}

resource "aws_iam_role" "spot_fleet_role" {
  name               = "qubole-ec2-spot-fleet-role"
  assume_role_policy = data.aws_iam_policy_document.spot_fleet_assume_role.json
}

resource "aws_iam_role_policy_attachment" "name" {
  role       = aws_iam_role.spot_fleet_role.name
  policy_arn = aws_iam_policy.spot_fleet_service_role.arn
}

resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
  description      = "Allows EC2 Spot to launch and manage spot instances."
}

resource "aws_iam_service_linked_role" "spotfleet" {
  aws_service_name = "spotfleet.amazonaws.com"
  description      = "Default EC2 Spot Fleet Service Linked Role"
}

resource "aws_iam_policy" "common_ec2_policy" {
  name   = "${var.name_prefix}-access-policy"
  policy = data.aws_iam_policy_document.common_ec2_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "DefaultLocationActions"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::${var.s3location}/*",
      "arn:aws:s3:::${var.s3location}",
    ]
  }

  statement {
    sid = "ListBucketsAndOthers"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name   = "${var.name_prefix}-s3-policy"
  policy = data.aws_iam_policy_document.s3_policy.json
}

