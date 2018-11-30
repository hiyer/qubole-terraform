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
Provisioning with terraform is a 3-command process. You need to run *terraform init* (once), *terraform plan* and *terraform apply*. After a successful application, you can run *terraform show* to see what was created or configured.
The following variables are required by this terraform template:
* prefix - this value is prefixed to the names of many of the resources
* project_tag - this value is used for the *project* tag on applicable resources.

Output of sample runs of *plan* and *show* are presented below:
```
terraform plan -var 'prefix=xyz' -var 'project_tag=hadoop2' -out app.tfplan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.network
      id:                               <computed>
      location:                         "eastus"
      name:                             "xyz_resource_group"
      tags.%:                           "1"
      tags.project:                     "hadoop2"

  + azurerm_storage_account.storage
      id:                               <computed>
      access_tier:                      "hot"
      account_encryption_source:        "Microsoft.Storage"
      account_kind:                     "Storage"
      account_replication_type:         "ZRS"
      account_tier:                     "Standard"
      enable_blob_encryption:           "true"
      enable_file_encryption:           "true"
      enable_https_traffic_only:        "false"
      identity.#:                       <computed>
      location:                         "eastus"
      name:                             "xyzstorage"
      primary_access_key:               <computed>
      primary_blob_connection_string:   <computed>
      primary_blob_endpoint:            <computed>
      primary_connection_string:        <computed>
      primary_file_endpoint:            <computed>
      primary_location:                 <computed>
      primary_queue_endpoint:           <computed>
      primary_table_endpoint:           <computed>
      resource_group_name:              "xyz_resource_group"
      secondary_access_key:             <computed>
      secondary_blob_connection_string: <computed>
      secondary_blob_endpoint:          <computed>
      secondary_connection_string:      <computed>
      secondary_location:               <computed>
      secondary_queue_endpoint:         <computed>
      secondary_table_endpoint:         <computed>
      tags.%:                           "1"
      tags.project:                     "hadoop2"

  + azurerm_storage_container.container
      id:                               <computed>
      container_access_type:            "private"
      name:                             "xyz-container"
      properties.%:                     <computed>
      resource_group_name:              "xyz_resource_group"
      storage_account_name:             "xyzstorage"

  + azurerm_virtual_network.network
      id:                               <computed>
      address_space.#:                  "1"
      address_space.0:                  "10.0.0.0/16"
      location:                         "eastus"
      name:                             "xyz-vnetwork"
	  resource_group_name:              "xyz_resource_group"
	  subnet.#:                         "1"
	  subnet.3127018043.address_prefix: "10.0.1.0/24"
	  subnet.3127018043.id:             <computed>
	  subnet.3127018043.name:           "xyz-subnet1"
	  subnet.3127018043.security_group: ""
	  tags.%:                           "1"
	        tags.project:                     "hadoop2"


	  Plan: 4 to add, 0 to change, 0 to destroy.

	  ------------------------------------------------------------------------

terraform show
azurerm_resource_group.network:
  id = /subscriptions/<redacted>/resourceGroups/xyz_resource_group
  location = eastus
  name = xyz_resource_group
  tags.% = 1
  tags.project = hadoop2
azurerm_storage_account.storage:
  id = /subscriptions/<redacted>/resourceGroups/xyz_resource_group/providers/Microsoft.Storage/storageAccounts/xyzstorage
  access_tier =
  account_encryption_source = Microsoft.Storage
  account_kind = Storage
  account_replication_type = ZRS
  account_tier = Standard
  account_type = Standard_ZRS
  enable_blob_encryption = true
  enable_file_encryption = true
  enable_https_traffic_only = false
  identity.# = 0
  location = eastus
  name = xyzstorage
  network_rules.# = 0
  primary_access_key = <redacted>
  primary_blob_connection_string = DefaultEndpointsProtocol=https;BlobEndpoint=https://xyzstorage.blob.core.windows.net/;AccountName=xyzstorage;AccountKey=<redacted>
  primary_blob_endpoint = https://xyzstorage.blob.core.windows.net/
  primary_connection_string = DefaultEndpointsProtocol=https;AccountName=xyzstorage;AccountKey=<redacted>;EndpointSuffix=core.windows.net
  primary_file_endpoint =
  primary_location = eastus
  primary_queue_endpoint =
  primary_table_endpoint =
  resource_group_name = xyz_resource_group
  secondary_access_key = <redacted>
  secondary_connection_string = DefaultEndpointsProtocol=https;AccountName=xyzstorage;AccountKey=<redacted>;EndpointSuffix=core.windows.net
  secondary_location =
  tags.% = 1
  tags.project = hadoop2
azurerm_storage_container.container:
  id = https://xyzstorage.blob.core.windows.net/xyz-container
  container_access_type = private
  name = xyz-container
  properties.% = 4
  properties.last_modified = Mon, 15 Oct 2018 10:07:50 GMT
  properties.lease_duration =
  properties.lease_state = available
  properties.lease_status = unlocked
  resource_group_name = xyz_resource_group
  storage_account_name = xyzstorage
azurerm_virtual_network.network:
  id = /subscriptions/<redacted>/resourceGroups/xyz_resource_group/providers/Microsoft.Network/virtualNetworks/xyz-vnetwork
  address_space.# = 1
  address_space.0 = 10.0.0.0/16
  dns_servers.# = 0
  location = eastus
  name = xyz-vnetwork
  resource_group_name = xyz_resource_group
  subnet.# = 1
  subnet.3127018043.address_prefix = 10.0.1.0/24
  subnet.3127018043.id = /subscriptions/<redacted>/resourceGroups/xyz_resource_group/providers/Microsoft.Network/virtualNetworks/xyz-vnetwork/subnets/xyz-subnet1
  subnet.3127018043.name = xyz-subnet1
  subnet.3127018043.security_group =
  tags.% = 1
  tags.project = hadoop2
```
