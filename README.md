# qubole-terraform
Terraform templates for setting up environments for use with [Qubole](https://www.qubole.com) clusters on Azure and AWS.
Includes the following configurations:
* AWS
  * [Private Subnet(s) with one public subnet and bastion host](aws/private-subnet/default)
  * [Private Subnet(s) with public subnet, bastion host and ec2 endpoint](aws/private-subnet/with-ec2-endpoint)
  * [Public Subnet(s)](aws/public-subnet)
  * [IAM Role](aws/iam-role)
  * [IAM User (keys-based access)](aws/iam-user)
