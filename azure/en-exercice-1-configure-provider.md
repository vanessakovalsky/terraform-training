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
- Finding hashicorp/kubernetes versions matching "2.17.0"...
- Installing hashicorp/kubernetes v2.17.0...
- Installed hashicorp/kubernetes v2.17.0 (signed by HashiCorp)

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

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

kubernetes_namespace.vanessakovalsky: Creating...
kubernetes_namespace.vanessakovalsky: Creation complete after 0s [id=vanessakovalsky]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.


# vanessakovalsky namespace created
❯❯ kubectl get ns
NAME              STATUS   AGE
default           Active   6d4h
kube-node-lease   Active   6d4h
be public Active 6d4hbe system Active 6d4hvanessakovalsky   Active   22s
```

## Deployment verification
* You can use kubectl to verify that your namespace is created
```
kubectl get ns vanessakovalsky
```
* Returns something like:
```
NAME           STATUS   AGE
vanessakovalsky   Active   3m52s
```

## Adding a deployment resource to our cluster
* We are going to add a deployment in the kubernetes sense, to do this add the following resource to the k8s.tf file:
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
        }
      }
    }
  }
}
```
* Here we have added a deployment in the Kubernetes sense.
* This will launch two replicas of a pod containing nginx
* Our pods will host a working nginx but it is not accessible since no service is associated with this pod.
* To be able to access this one, we must add a service
* Add to your k8s.tf file above your instance resource the resource below
```
resource "kubernetes_service" "nginxsvc" {
metadata {    name = "terraform-example-svc"
    namespace = "vanessakovalsky"
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
```
* We can now deploy our service and deployment:
```
terraform init && terraform apply
```
* Which will give a result similar to:
```
@TOCOPY
```
* Check now via kubectl that your deployment and your service are well created
* Then launch minikube tunnel and access your web page on the address provided by minikube (if necessary to retrieve the URL: `minikube service terraform-example-svc -n vanessakovalsky --url` )

## Delete resource
* The exercises being finished, we are going to delete the resources with the command
```
terraform destroy
```
* Which will give a result similar to:
```
@TOCOPY
```