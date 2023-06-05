# Exercise 4 - Modules

## Goals
This exercise aims to:
* learn how to create a module
* to use our module in our terraform files
* to create a deployment containing wordpress and all associated resources

## Module structure
* Our module will have the following structure:
    * LICENSE: license under which your module will be distributed. It will inform people who use it of the conditions under which it was made available.
    * README.md: will contain documentation in markdown format describing how to use your module.
    * main.tf: will contain the main code for your Terraform configuration of your module.
    * variables.tf: will contain the variables of your module. When your module is used by others, the variables will be configured as arguments in the module block which we will see later in this article.
    * outputs.tf: as its name suggests, it will contain the output variables of your module. They are often used to pass information about parts of your infrastructure defined by the module to other parts of your configuration.
* Create a `modules` folder and inside it a `k8s-wordpress` folder
```
mkdir -p modules/k8s-wordpress
```

## Module creation
* Create the LICENSE file and choose your license for the module, for example [Apache](https://www.apache.org/licenses/LICENSE-2.0) or [GPL](https://www.gnu.org/ licenses/gpl-3.0.html)
* Then create a README.md file which contains the following documentation (which you can adapt if you wish)
````
# K8S - Wordpress

This module provisions the resources needed to deploy a Wordpress site in a Kubernetes cluster.
## Usage

```hcl
module "<module name>" {
    source = "path of your module"
    site_name = "<UNIQ SITE NAME>"
    tags = {
        key   = "<value>"
    }
}
```
When the site is deployed you can connect to it and start the installation of Wordpress
````

* Using the [kubernetes provider documentation](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) define the following resources:    
    * Service de type NodePort
    * PVC for storage
    * Deployment for Wordpress
    * Deployment for MySQL
    * Secret for mysql root password, mysql password for wordpress, password for wordpress user
    * Configmap for db and wordpress users
    * It is not necessary to define a provider in a module. Indeed, the module being imported into another configuration element, the provider is inherited from the parent configuration.
    * Create a `variables.tf` file to define the app_name and namespace variable to be used in K8s resources
    * Finally, in order to retrieve the site address, create an output file that retrieves the node's IP address from the service and the exposed port
* All the elements of our modules are ready, all that remains is to use them

## Use our module

* Go back to root module `main.tf`
* The syntax for using a module is as follows:
```
module "<NAME>" { 
    source = "<SOURCE>" 
    [ARGUMENTS ...] 
  }
```
NAME: identifier that can be used in the terraform code to refer to our modulesource: relative path of our moduleARGUMENTS: specific input variables of our module
* Add at the end of the `main.tf` file the following code
```
module "k8s_wordpress" {
    source = "./modules/k8s-wordpress"
    app_name = "devopssec-terraform"
    namespace = "mynamespace
}
```
* Let's run the code to see if everything is ok:
```
terraform init && terraform apply
```
* After answering yes, you should see the following lines:
```
@TOCOPY
```
* Your wordpress is deployed, you can go to see it via kubectl and display it in your browser

## Delete resource

* The exercises being finished, we are going to delete the resources with the command
```
terraform destroy
```

## Useful link 

- Wordpress on K8S : https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/ 