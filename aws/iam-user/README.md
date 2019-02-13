# IAM User and Policies

This template creates an IAM user and associated policies for use with Qubole clusters.

# Inputs## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| account\_id | Account id | string | n/a | yes |
| qubole\_account\_id | Qubole Trusted Account Id | string | n/a | yes |
| qubole\_external\_id | Qubole External Id | string | n/a | yes |
| region | Region to create the role/policy in | string | `"us-west-2"` | no |
| role\_name | Role name | string | `"Qubole access role"` | no |
| s3location | S3 location to save logs, outputs, etc | string | n/a | yes |
| vpc\_id | VPC to restrict the compute resources to | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| role\_arn |  |

