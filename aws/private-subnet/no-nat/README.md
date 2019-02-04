# Private subnet with no NAT

## Description
This configuration does not use a NAT for the private subnet. Instead the necessary external resources are exposed via endpoints - one each for S3 and EC2 API. The advantage of such a configuration is that we don't need to allow any traffic to or from 0.0.0.0/0 in the private subnet. Note that this means that the only external traffic allowed is via the endpoint, so commands like `pip install`, `rpm install` etc. will not work from cluster nodes. This configuration is only recommended for highly secure requirements.

NB: this configuration only works for accounts on us.qubole.com

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_key\_name | Key Pair to use for the bastion node | string | - | yes |
| cidr\_block | CIDR block for the VPC | string | `10.0.0.0/16` | no |
| num\_pvt\_subnets | Number of private subnets to create for cluster nodes. | string | `1` | no |
| prefix | Prefix to apply for name tags | string | - | yes |
| private\_subnet\_cidr | CIDR for private subnet. Auto-calculated if not specified. Ignored when using multiple subnets. | string | `` | no |
| public\_subnet\_cidr | CIDR for the public subnet. Auto-calculated if not specified. Ignored when using multiple subnets. | string | `` | no |
| region | AWS region | string | `us-west-2` | no |
| ssh\_public\_key | Public key to use for bastion node. This is the account key in cluster UI | string | - | yes |
| tags | Other tags to apply | map | `<map>` | no |
| whitelist\_ip | List of IPs to whitelist SSH from | list | - | yes |
| whitelist\_outgoing | Public IP to whitelist outgoing traffic to. | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_ip | IP address of the bastion node |
| private\_subnet\_id | Private subnet Id |
| public\_subnet\_id | Public subnet Id |
| vpc\_endpoint | VPC EC2 Endpoint |
| vpc\_id | VPC Id |
