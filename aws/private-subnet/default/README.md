# Private Subnet Configuration

This template creates a VPC for use with Qubole clusters in a private subnet based on the [VPC Scenario 2](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html).

The clusters reside in the private subnet, and there is a bastion host in the public subnet for Qubole machines to be able to SSH into them. 

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_key\_name | Key Pair for the bastion node | string | n/a | yes |
| bastion\_node\_instance\_type | Instance type for bastion node | string | `"t3.small"` | no |
| cidr\_block | CIDR block for the VPC | string | `"10.0.0.0/16"` | no |
| num\_pvt\_subnets | Number of private subnets to create for cluster nodes. Do not specify private_subnet_cidr if using multiple subnets | string | `"1"` | no |
| prefix | Prefix to apply for name tags | string | n/a | yes |
| private\_subnet\_cidr | CIDR for private subnet. Auto-calculated if not specified. Ignored when using multiple subnets. | string | `""` | no |
| public\_subnet\_cidr | CIDR for public subnet. Auto-calculated if not specified. Ignored when using multiple subnets. | string | `""` | no |
| region | AWS Region | string | `"us-west-2"` | no |
| ssh\_public\_key | SSH public key for SSH'ing into your bastion node. This is the Account key in the cluster details page | string | n/a | yes |
| tags | Tags to apply on applicable resources It is *highly recommended* to specify tags so you can identify your resources. | map | `<map>` | no |
| whitelist\_ip | List of IPs to whitelist SSH from | list | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_ip | IP address of the bastion node |
| private\_subnet\_id | Private subnet id(s) |
| public\_subnet\_id | Public subnet id |
| vpc\_id | VPC Id |

