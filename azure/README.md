# Introduction

This terraform template creates storage and compute resources required for running QDS on Azure. It uses [Terraform](https://www.terraform.io) to create resources and is based on the steps described [here](https://docs.qubole.com/en/latest/quick-start-guide/Azure-quick-start-guide/QuboleConnect/detailed-azure-qubole-steps/azure-Azure-setup.html).

## How to Use

### Creating a service principal
First, create a service principal as described [here](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html). You will need the following values from running the commands there to proceed:
1. Subscription Id (use the Pay-As-You-Go subscription)
2. Client Id
3. Client Secret
4. Tenant Id

You can also use an existing service principal if you have one.

### Using the service principal
Configure terraform to use the service principal as described [here](https://www.terraform.io/docs/providers/azurerm/index.html#argument-reference). For example, if using environment variables, you will need the following:
* ARM_SUBSCRIPTION_ID
* ARM_CLIENT_ID
* ARM_CLIENT_SECRET
* ARM_TENANT_ID

### Running terraform
Provisioning with terraform is a 3-command process. You need to run *terraform init* (once), *terraform plan* and *terraform apply*. 

To see the list of required and configurable inputs for the template, see [here](variables.tf). Any variable that does not have a default value is a required input.
