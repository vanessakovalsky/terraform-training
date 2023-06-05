# Exercise 2 - Input and output variables

## Goals
This exercise aims to:
* Create and use input variables
* Create and use output variables

## Input Variables

### Declare an input variable

* Variables are composed of a name, a type, a default value and a description. Only the name is required.
* To declare a variable we use a `variable` type block and its label is then the name of our variable
```
variable "name" {
  type        = string
  description = "Name of the deployment"
}
```

### Accessing an input variable

* To access a variable, you can use the variable by prefixing its name with the keyword `var.`
```
resource "kubernetes_deployment" "nginx" {
metadata {    name = var.name
...
```
* Alternate syntax is possible by surrounding the name `var.name` with braces and preceding them with a $ symbol. This second syntax is mandatory if you need to concatenate the value of multiple variables:
```
resource "kubernetes_deployment" "nginx" {
metadata {    name = "${var.name}"
...
```

### Set the value of a variable
* It is possible to define the value of a variable in different ways:
  * using option -var `VARNAME=valUE` during terraform apply command
  * using a file (this one will then have the extension .tfvars) and calling this file with the command `terraform apply -var-file=k8s.tfvars`
  * using the interactive mode, if the variables are not specified, then terraform asks you to enter the values interactively. /!\ In this case the values are not saved.

## Output Variables 

* The output variables make it possible to retrieve information on its infrastructure such as an identifier or an IP address for example.
* We then use an `output` type block and we define what must be contained in this variable. The possible values then depend on the resource created
```
output "port" {
  value = "${kubernetes_service.nginxsvc.spec.0.port.0.port}"
}
```

## Application exercise on our project:
* Create a vars.tf file which will contain the definition of the following 5 variables:
  * name: deployment name
  * app_name: app name
  * namespace: name of the namespace to create and use
  * image: identifier and version of the image to use
  * port: port to expose in the service* In the k8s.tf file, replace hard values with a call to its variables
* Create a terraform.tfvars file which will contain the key/value pairs of our variables
* Define an output variable that returns the IP address of the node port
* Apply your changes with the command `terraform init &amp;&amp; terraform apply`
* Use the returned IP address to check if your deployment is still working
* Then check the application of your variables is correct with kubectl

## Delete resource

* The exercises being finished, we are going to delete the resources with the command
```
terraform destroy
```
