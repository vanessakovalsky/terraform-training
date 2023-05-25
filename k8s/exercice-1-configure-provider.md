# Exercice 1 - Configurer un provider et créer une première ressource

## Pré-requis
* Afin de pouvoir déployer sur K8s, nous utilisons Minikube
* Minikube doit donc être installé et un cluster k8s démarré

## Configuration du provider

* Commençons par configurer le provider (fournisseur) que vous souhaitez utiliser. Créer un fichier nommé provider.tf. Ensuite, mettre le code suivant (en adaptant avec vos informations d'accès):
```
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.17.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

```
* Nous indiquons à Terrform différente information :
    - le provider avec le label "kubernetes'
    - le chemin vers le fichier de configuration
    - le contexte à utilisé


## Ajout de la ressource

* Chaque fournisseur propose différents types de ressources. 
* Commençons par une ressource simple, un namespace
* Ajouter le code suivant à votre fichier k8s.tf :
```
resource "kubernetes_namespace" "vanessakovalsky" {
    metadata {
        name = "vanessakovalsky"
    }
}
```
* La syntaxe générale d'une ressource Terraform est la suivante :
```
resource "<FOURNISSEUR>_<TYPE>" "<NOM>" {
    [CONFIG …]
}
```
    * FOURNISSEUR : c'est le nom d'un fournisseur (ici le provider "kuberenetes").
    * TYPE : c'est le type de ressources à créer dans ce fournisseur (ici c'est un namespace)
    * NOM : c'est un identifiant que vous pouvez utiliser dans le code Terraform pour faire référence à cette ressource (ici "vanessakovalsky")
    * CONFIG : se compose de un ou plusieurs arguments spécifiques à cette ressource, dans notre cas :
        * metadata : ce sont les méta données de notre ressources K8s


## Lancement du déploiement

* Pour lancer notre déploiement, nous ouvrons un terminal et nous mettons dans le dossier contenant notre fichier main.tf
* Puis exécuter la commande :
```
terraform init
```
* Vous obtenez un résultat ressemblant à :
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
* Un nouveau fichier caché .terraform est alors apparu dans votre dossier
* Demander maintenant à terraform de créer le plan d'éxecution, qui détermine les actions nécessaires pour atteindre l'état souhaité dans votre fichier main.tf . 
* Pour cela exécuter la commande
```
terraform plan
```
* Qui donne un résultat similaire à :
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # kubernetes_namespace.vanessakovalsky will be created
  + resource "kubernetes_namespace" "vanessakovalsky" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + name             = "vanessakovalsky"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```
* Vous voyez alors différentes informations : 
    * des ressources ajoutées avec le symbole + 
    * des ressources supprimées avec le symbole - 
    * des ressources modifiées avec le symbole ~
* Ici nous avons seulement un ajout
* Enfin, demander à terraform d'éxecuter le plan en utilisant la commande :
```
terraform apply
```
* Qui donne un résultat similaire à (pensez à taper yes pour approuver l'application) :
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # kubernetes_namespace.vanessakovalsky will be created
  + resource "kubernetes_namespace" "vanessakovalsky" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
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
kube-public       Active   6d4h
kube-system       Active   6d4h
vanessakovalsky   Active   22s
```

## Vérification du déploiement 

* Vous pouvez ouvrir la kubectl pour vérifier que votre instance est bien crée
```
kubectl get ns vanessakovalsky
```
* Renvoit quelque chose comme :
```
NAME           STATUS   AGE
vanessakovalsky   Active   3m52s
```

## Ajout d'une ressource deploiement à notre cluster

* Nous allons ajouter un déploiement au sens kubernetes, pour cela ajouter dans le fichier k8s.tf la ressource suivante :
```
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "terraform-example"
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
      metadata {
        labels = {
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
* Ici nous avons ajouter un déploiement au sens Kubernetes. 
* Celui-ci lancera deux replicas d'un pod contenant nginx

* Nos pods hebergeront un nginx fonctionnel mais il n'est pas accessible puisqu'aucun service n'est associé à ce pod.
* Pour pouvoir accéder à celle-ci, nous devons ajouter un service
* Ajouter a votre fichier k8s.tf au dessus de votre ressource instance la ressource ci-dessous
```
resource "kubernetes_service" "nginxsvc" {
  metadata {
    name = "terraform-example-svc"
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
* Nous pouvons maintenant déployer notre service et notre deploiement :
```
terraform init && terraform apply
```
* Qui donnera un résultat similaire à :
```
@TOCOPY
```
* Vérifier maintenant via kubectl que votre deploiement et votre service sont bien créé
* Puis lancer minikube tunnel et accéder à votre page web sur l'adresse fournit par minikube (si besoin pour recuperer l'URL : `minikube service terraform-example-svc -n vanessakovalsky --url` )

## Suppression de la ressource
* Les exercices étant terminer, nous allons supprimer les ressources avec la commande 
```
terraform destroy
```
* Qui donnera un résultat similaire à :
```
@TOCOPY
```