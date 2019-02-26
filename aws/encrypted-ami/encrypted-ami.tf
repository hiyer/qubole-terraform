provider "aws" {
  region = "${var.region}"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.prefix}-copy-ami-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    sid = "ExecuteSSMAutomation"
    actions = [
      "ssm:StartAutomationExecution",
      "ssm:GetAutomationExecution",
      "ssm:DescribeAutomationExecutions",
      "ssm:DescribeAutomationStepExecutions"
    ]
    resources = [ "*" ]
  }
  statement {
    sid = "LogToCloudwatch"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = [ "arn:aws:logs:*:*:*" ]
  }
}

resource "aws_iam_policy" "lambda_role" {
  name = "${var.prefix}-copy-ami-lambda-policy"
  policy = "${data.aws_iam_policy_document.lambda_role.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_role" {
  role = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_role.arn}"
}

data "aws_iam_policy_document" "automation_assume_role" {
  statement {
    sid = "CopyAMI"
    actions = [
        "ec2:DescribeImages",
        "ec2:DescribeTags",
        "ec2:CreateTags",
        "ec2:CopyImage",
        "ec2:CreateImage"
    ]
    resources = [ "*" ]
  }
}

locals {
  zip_file_name = "copy-ami.zip"
}

data "external" "deploy_document" {
  program = ["bash", "zip_file.sh"]
}

resource "aws_lambda_function" "copy_ami_lambda" {
  filename = "${data.external.deploy_document.result.deploydoc}"
  function_name = "${var.prefix}-copy-ami-function"
  handler = "lambda_function.lambda_handler"
  role = "${aws_iam_role.lambda_role.arn}"
  description = "Creates encrypted copy of Qubole AMI"
  runtime = "python2.7"
  timeout = 30
  source_code_hash = "${base64sha256(file(data.external.deploy_document.result.deploydoc))}"
  environment {
    variables = {
      AUTOMATION_DOCUMENT_NAME = "${aws_ssm_document.automation_document.name}"
    }
  }
}

resource "aws_iam_policy" "automation_assume_role" {
  name = "${var.prefix}-copy-ami-ssm-policy"
  policy = "${data.aws_iam_policy_document.automation_assume_role.json}"
}

resource "aws_iam_role" "automation_assume_role" {
  name = "${var.prefix}-copy-ami-ssm-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ssm.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "automation_assume_role" {
  role = "${aws_iam_role.automation_assume_role.name}"
  policy_arn = "${aws_iam_policy.automation_assume_role.arn}"
}

resource "aws_sns_topic_subscription" "new_ami_deployed_target" {
  topic_arn = "${var.topic_arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.copy_ami_lambda.arn}"
}

resource "aws_ssm_document" "automation_document" {
  name = "QBL-${var.prefix}-CreateEncyptedCopyOfAMI"
  document_format = "YAML"
  document_type = "Automation"
  content = <<DOC
---
description: "Create Encrypted copy of AMI"
schemaVersion: "0.3"
assumeRole: "${aws_iam_role.automation_assume_role.arn}"
parameters:
  SourceImageId:
    type: "String"
    description: "Id of source AMI"
  SourceImageRegion:
    type: "String"
    description: "Region of the above AMI"
    default: "us-east-1"
mainSteps:
- name: createEncryptedCopy
  action: aws:copyImage
  maxAttempts: 3
  onFailure: Abort
  inputs:
    SourceImageId: "{{ SourceImageId }}"
    SourceRegion: "{{ SourceImageRegion }}"
    ImageName: Encrypted Copy of Qubole AMI
    Encrypted: true
DOC
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.copy_ami_lambda.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${var.topic_arn}"
}

