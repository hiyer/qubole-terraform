resource "aws_iam_role_policy" "qubole_policy" {
  name = "Qubole Policy"

  policy = <<EOF
{ "Version": "2019-30-01",
       "Statement":
       [
       { "Sid": "NonResourceBasedPermissions",
         "Effect": "Allow",
         "Action": [
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
           "sts:DecodeAuthorizationMessage" ],
         "Resource": [ "*" ]
       },
       { "Sid": "AllowInstanceActions",
         "Effect": "Allow",
         "Action": [
           "ec2:StartInstances",
           "ec2:StopInstances",
           "ec2:ModifyInstanceAttribute",
           "ec2:TerminateInstances",
           "ec2:AttachVolume",
           "ec2:DetachVolume",
           "ec2:CreateTags",
           "ec2:DeleteTags" ],
         "Resource": [ "arn:aws:ec2:<AWS Region>:<AWS Account ID>:instance/*" ],
         "Condition": {
           "StringEquals": {
                "ec2:InstanceProfile": "arn:aws:iam::<AWS Account ID>:instance-profile/<AWS Role Name>"
           }
         }
       },
       { "Sid": "RunInstanceWithRole",
         "Effect": "Allow",
         "Action": [
           "ec2:RunInstances",
           "ec2:CreateTags",
           "ec2:DeleteTags" ],
       "Resource": [ "arn:aws:ec2:<AWS Region>:<AWS Account ID>:instance/*" ],
       "Condition": {
           "StringEquals": {
               "ec2:InstanceProfile": "arn:aws:iam::<AWS Account ID>:instance-profile/<AWS Role Name>"
           }
         }
       },
       { "Sid": "RunInstanceInSubnet",
         "Effect": "Allow",
         "Action": [
           "ec2:RunInstances",
           "ec2:CreateTags",
           "ec2:DeleteTags" ],
       "Resource": [ "arn:aws:ec2:<AWS Region>:<AWS Account ID>:subnet/*" ],
       "Condition": {
           "StringEquals": {
                "ec2:vpc": "arn:aws:ec2:<AWS Region>:<AWS Account ID>:vpc/<VPC ID>"
           }
         }
       },
       { "Sid": "RunInstanceResourcePermissions",
         "Effect": "Allow",
         "Action": [
           "ec2:RunInstances",
           "ec2:CreateTags",
           "ec2:DeleteTags" ],
       "Resource": [
           "arn:aws:ec2:<AWS Region>::image/*",
           "arn:aws:ec2:<AWS Region>::snapshot/*",
           "arn:aws:ec2:<AWS Region>:<AWS Account ID>:volume/*",
           "arn:aws:ec2:<AWS Region>:<AWS Account ID>:network-interface/*",
           "arn:aws:ec2:<AWS Region>:<AWS Account ID>:key-pair/*",
           "arn:aws:ec2:<AWS Region>:<AWS Account ID>:security-group/*" ]
       },
       { "Sid": "SecurityGroupActions",
         "Effect": "Allow",
         "Action": [
           "ec2:AuthorizeSecurityGroupEgress",
           "ec2:AuthorizeSecurityGroupIngress",
           "ec2:RevokeSecurityGroupIngress",
           "ec2:RevokeSecurityGroupEgress",
           "ec2:DeleteSecurityGroup",
           "ec2:CreateTags",
           "ec2:DeleteTags" ],
       "Resource": [ "*" ],
       "Condition": {
           "StringEquals": {
               "ec2:vpc": "arn:aws:ec2:<AWS Region>:<AWS Account ID>:vpc/<VPC ID>"
           }
         }
       },
       { "Sid": "CreateAndDeleteVolumeActions",
         "Effect": "Allow",
         "Action": [
           "ec2:CreateVolume",
           "ec2:DeleteVolume",
           "ec2:CreateTags",
           "ec2:DeleteTags" ],
       "Resource": [
           "arn:aws:ec2:<AWS Region>:<AWS Account ID>:volume/*" ]
       },
       {
       "Effect": "Allow",
       "Action": [
          "iam:CreateServiceLinkedRole",
          "iam:PutRolePolicy"
       ],
       "Resource": ["arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot", "arn:aws:iam::*:role/aws-service-role/spotfleet.amazonaws.com/AWSServiceRoleForEC2SpotFleet"],
       "Condition": {
          "StringLike": {
              "iam:AWSServiceName": ["spot.amazonaws.com","spotfleet.amazonaws.com"]
          }
       }
       }
     ]
  }
  EOF
}