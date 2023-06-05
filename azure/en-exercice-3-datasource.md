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
data "kubernetes_pod" "podnginx" {
  metadata {    
    name = "terraform-example"  
  }
}


```
* You then retrieve the information on the podnginx

## Use data from a data source

* To retrieve data from a Data source, the following attribute reference syntax is used
```
data.<DATA_SOURCE_NAME.≶NAME>.<ATTRIBUTE>
```
* The list of retrievable attributes is also available in the [official documentation](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/pod#spec)
* Here we retrieve the list of configmaps via our data source:
```
data "kubernetes_config_map" "example" {
  metadata {    
    name = "my-config"
  }
}
```
* Then we use the configmap in our deployment
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
