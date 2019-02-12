# Private subnet with no global whitelist

## Description
This configuration does not need to whitelist 0.0.0.0/0 for the subnets. Instead the necessary external resources are exposed via endpoints - one each for S3 and EC2 API. Note that this means that the only external traffic allowed is via the endpoint, so commands like `pip install`, `rpm install` etc. will not work from cluster nodes. This configuration is only recommended for highly secure requirements.

NB: this is a sample configuration that does not work with Qubole yet. Please get in touch with Qubole support if you would like to use this configuration.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_key\_name | Key Pair to use for the bastion node | string | n/a | yes |
| cidr\_block | CIDR block for the VPC | string | `"10.0.0.0/16"` | no |
| num\_pvt\_subnets | Number of private subnets to create for cluster nodes. | string | `"1"` | no |
| prefix | Prefix to apply for name tags | string | n/a | yes |
| private\_subnet\_cidr | CIDR for private subnet. Auto-calculated if not specified. Ignored when using multiple subnets. | string | `""` | no |
| public\_subnet\_cidr | CIDR for the public subnet. Auto-calculated if not specified. Ignored when using multiple subnets. | string | `""` | no |
| region | AWS region | string | `"us-west-2"` | no |
| ssh\_public\_key | Public key to use for bastion node. This is the account key in cluster UI | string | n/a | yes |
| tags | Other tags to apply. It is *highly recommended* to specify tags so you can identify your resources. | map | `<map>` | no |
| whitelist\_ip | List of IPs to whitelist SSH from | list | n/a | yes |
| whitelist\_outgoing | Public IP to whitelist outgoing traffic to. | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_ip | IP address of the bastion node |
| private\_subnet\_id | Private subnet Id |
| public\_subnet\_id | Public subnet Id |
| vpc\_endpoint | VPC EC2 Endpoint |
| vpc\_id | VPC Id |

