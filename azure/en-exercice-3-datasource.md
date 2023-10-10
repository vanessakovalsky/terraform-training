# Exercise 3 - Defining and using a data source

## Goals

This exercise aims to:
* know how to define a data source
* to be able to use the data source defined in its code

## Create a Datasource

* Here is what the syntax for using the creation of a Data source looks like, which remains very similar to the syntax of a resource:
```
data "<DATA_SOURCE_NAME>" "<NAME>" {
    [CONFIG ...]
}
```
* DATA_SOURCE_NAME: corresponds to the resource on which you want to retrieve information, the list of all Data Sources is available here.
* NAME: identifier that you can use in Terraform code to refer to this data source.
* CONFIG: one or more arguments that are specific to this Data Source.
* In our example, we could for example ask Terraform to go and retrieve the information on the nginx pod
* To define our data source we can now in our terraform code, ask it to retrieve pod information:
```
data "azurerm_platform_image" "search" {
  location  = "West Europe"
  publisher = "canonical"
  offer     = "0001-com-ubuntu-minimal-jammy"
  sku       = "minimal-22_04-lts-ARM"
}


```
* You then retrieve the information on image you want to use for create your VM instance

## Use data from a data source

* To retrieve data from a Data source, the following attribute reference syntax is used
```
data.<DATA_SOURCE_NAME.≶NAME>.<ATTRIBUTE>
```
* The list of retrievable attributes is also available in the [official documentation]([https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/pod#spec](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/platform_image#attributes-reference))
* Here we retrieve the id of image via our data source:
```
output "image" {
  value = data.azurerm_platform_image.search.id
}
```
* Then we use the image id in our resource vm instance
```
resource "kubernetes_deployment" "nginx" {
  metadata {    name = "terraform-example"
    labels = {
      app = "MyExampleApp"
    }
    namespace = "vanessakovalsky"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "MyExampleApp"
      }
    }

    template {
  metadata {        labels = {
          app = "MyExampleApp"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "example"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          env_from {
            config_map_ref {
                name = data.kubernetes_config_map.kubernetes_config_map.my-config
            }
          }
        }
      }
    }
  }
}
```
* You must then create the configmap my-config either with kubectl or by adding the resource to the terraform files* To apply our modification, use the command: `terraform init &amp;&amp; terraform apply`
* Then return to verify with kubectl

## Delete resource
* The exercise being finished, we are going to delete the resources with the command
```
terraform destroy
```
