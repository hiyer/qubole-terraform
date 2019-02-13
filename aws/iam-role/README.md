# IAM Role and Policies

This template creates an IAM role and associated policies for use with Qubole clusters.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| account\_id | Account id | string | n/a | yes |
| qubole\_account\_id | Qubole Trusted Account Id | string | n/a | yes |
| qubole\_external\_ids | Qubole External Id(s) | list | n/a | yes |
| region | Region of the vpc where compute resources will be provisioned | string | `"us-west-2"` | no |
| role\_name | Role name | string | `"Qubole-role"` | no |
| s3location | S3 location to save logs, outputs, etc | string | n/a | yes |
| vpc\_id | VPC to restrict the compute resources to | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instance\_profile\_arn | ARN of the instance profile |
| role\_arn | ARN of the role |

