# Private Subnet Configuration

This template creates a VPC for use with Qubole clusters in a private subnet based on the [VPC Scenario 2](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html).

The clusters reside in the private subnet, and there is a bastion host in the public subnet for Qubole machines to be able to SSH into them. 

To see the list of required and configurable inputs for the template, see [here](variables.tf). Any variable that does not have a default value is a required input.