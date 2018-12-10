# Private Subnet with NACLs

This configuration is a variation of the private subnet case described [here](../private-subnet). Here the bastion security is imposed by NACLs in addition to security groups. This requires the bastion node to be placed in a separate public subnet. Unless you have very specific security requirements, it is recommended to use the simpler private subnet configuration.

For the list of required and configurable inputs, see [here](variables.tf). Any variable without a default value is a required input. For convenience it is recommended to use a file to provide the variable inputs.