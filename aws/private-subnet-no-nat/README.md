# Private subnet with no NAT

## Description
This configuration does not use a NAT for the private subnet. Instead the necessary external resources are exposed via endpoints - one each for S3 and EC2 API. The advantage of such a configuration is that we don't need to allow any traffic to or from 0.0.0.0/0 in the private subnet. Note that this means that the only external traffic allowed is via the endpoint, so commands like `pip install`, `rpm install` etc. will not work from cluster nodes. This configuration is only recommended for highly secure requirements.
