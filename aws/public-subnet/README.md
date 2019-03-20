# Public Subnet Configuration

This template creates a VPC for use with Qubole clusters in a public subnet based on the [VPC Scenario 1](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario1.html).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cidr\_block | CIDR block for the VPC | string | `"10.0.0.0/16"` | no |
| num\_subnets | Number of subnets to create | string | `"1"` | no |
| prefix | Prefix to be used for 'name' tags. e.g. the vpc would be named _prefix_-vpc | string | n/a | yes |
| public\_subnet\_cidr | CIDR block for the subnet. Auto-calculated if not specified. Ignored when using multiple subnets | string | `""` | no |
| region | AWS region to create the resources in | string | `"us-west-2"` | no |
| tags | Other tags to apply. It is *highly recommended* to specify tags so you can identify your resources. | map | `<map>` | no |
| whitelist\_ip | List of IPs to whitelist SSH from | list | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| public\_subnet\_ids | Id of the public subnet(s) |
| vpc\_id | Id of the VPC |

