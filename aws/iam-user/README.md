# IAM User and Policies

This template creates an IAM user and associated policies for use with Qubole clusters.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| account\_id | Account id | string | n/a | yes |
| region | Region of the vpc where compute resources will be provisioned | string | `"us-west-2"` | no |
| s3location | S3 location to save logs, outputs, etc | string | n/a | yes |
| user\_name | User name | string | `"Qubole-user"` | no |
| vpc\_ids | VPC to restrict the compute resources to | list(map(string)) | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | Access Key Id |
| secret\_access\_key | Secret Access Key |
| user\_name | User name |

