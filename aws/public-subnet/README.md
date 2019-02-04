# Public Subnet Configuration

This template creates a VPC for use with Qubole clusters in a public subnet based on the [VPC Scenario 1](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario1.html).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cidr\_block | cidr block for the vpc | string | `"10.0.0.0/16"` | no |
| prefix | prefix to apply for name tags | string | n/a | yes |
| public\_subnet\_cidr | cidr for public subnet | string | `"10.0.0.0/24"` | no |
| region | aws region | string | `"us-west-2"` | no |
| tags | other tags to apply | map | `<map>` | no |
| whitelist\_ip | Public IPs to whitelist SSH traffic from(either NAT or tunnel servers) | list | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| public\_subnet\_id |  |
| vpc\_id |  |

