# Exercise 1 - Configure a provider and create a first resource

## Prerequisites

* In order to be able to deploy on Azure, you need an azure subscription
* You also need to [install Azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and configure connexion with command `az login`

## Configure provider

* Let's start by configuring the provider you want to use. Create a file named azure.tf. Then put the following code (adapting with your access information):
```
terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "=3.0.1"
        }
    }
}

provider "azurerm" {
    features  {}
}

```
* We indicate to Terrform different information:
  - the provider with the label `azurerm`
  - block features is mandatory for azure provider

## Adding resource

* Each provider offers different types of resources.
* Let's start with a simple resource, a resource groupe
* Add the following code to your azure.tf file:
```
resource "azurerm_resource_group" "demo" {
    name = "demo-resources"
    location = "West Europe"
}
```
* The general syntax of a Terraform resource is as follow:
```
resource "<PROVIDER>_<TYPE>" "<NAME>" {
    [CONFIG …]
}
```
* PROVIDER: this is the name of a provider (here the `azurerm` provider).
* TYPE: this is the type of resources to create in this provider (here it is a namespace)
* NAME: this is an identifier that you can use in Terraform code to refer to this resource (here `demo`)
* CONFIG: consists of one or more arguments specific to this resource, in our case:

## Launching the deployment
* To start our deployment, we open a terminal and put in the folder containing our main.tf file
* Then run the command:
```
terraform init
```
* You get a result similar to:
```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "3.75.0"...
- Installing hashicorp/azurerm v3.75.0...
- Installed hashicorp/azurerm v3.75.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
* A new hidden .terraform file then appeared in your folder
* Now tell terraform to create the execution plan, which determines the actions needed to reach the desired state in your main.tf file.* For this execute the command
```
terraform plan
```
* Which gives a result similar to:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # kubernetes_namespace.vanessakovalsky will be created
  + resource "kubernetes_namespace" "vanessakovalsky" {
      + id = (known after apply)

+ metadata {          + generation       = (known after apply)
          + name             = "vanessakovalsky"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```
* You will then see different information:
  * resources added with the symbol +
  * resources deleted with the symbol -
  * resources modified with the symbol ~
* Here we have only an addition
* Finally, ask terraform to execute the plan using the command:
```
terraform apply
```
* Which gives a result similar to (remember to type yes to approve the application):
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

# azurerm_resource_group.example will be created
  + resource "azurerm_resource_group" "example" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "myressourcegroupe"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.example: Creating...
azurerm_resource_group.example: Creation complete after 0s [id=/subscriptions/78b9a3d9-a777-4dad-8f72-5fc24f431d13/resourceGroups/myressourcegroupe]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Deployment verification
* You can use Azure Portal to verify that your resource group is created
* Just connect to https://portal.azure.com/ 
* Go to ressources Groups and check if your new one is present

## Adding a deployment resource to our terraform file
* We are going to add a virtual machine as resource, to do this add the following resource to the main.tf file:
```
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
   publisher = "West Europe"
   offer = "Canonical"
   sku = "0001-com-ubuntu-server-jammy"
   version = "22_04-lts"
  }
}
```
* Here we have added a linux virtual machine, and all its dependencies (virtual network, subnet and network interface)
* This will launch a linux virtual machine with Ubuntu and all other resources needed
* Assure that you get an ssh public key in path specified on line `public_key = file("~/.ssh/id_rsa.pub")`, if not change path or generate an ssh key
* We can now deploy our service and deployment:
```
terraform init && terraform apply
```
* Which will give a result similar to:
```
@TOCOPY
```
* Check now via Azure portal than your virtual machine is launched, and you can access it with your ssh key. 

## Delete resource
* The exercises being finished, we are going to delete the resources with the command
```
terraform destroy
```
* Which will give a result similar to:
```
@TOCOPY
```
