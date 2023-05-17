# Exercice 3 - Définition et utilisation d'une data source

## Objectifs
Cet exercice a pour objectifs : 
* de savoir définir une source de données 
* d'être capable d'utiliser la source de données définie dans son code

## Créer une Data source

* Voici à quoi ressemble la syntaxe d'utilisation de la création d'une Data source qui reste très similaire à la syntaxe d'une ressource :
```
data "<DATA_SOURCE_NAME>" "≶NAME>" {
    [CONFIG ...]
}
```
   * DATA_SOURCE_NAME : correspond à la ressource sur laquelle vous souhaitez récupérer des informations, la liste de toutes les Data Sources est disponible ici.
   * NAME : identifiant que vous pouvez utiliser dans le code Terraform pour faire référence à cette source de données.
   * CONFIG : un ou plusieurs arguments qui sont spécifiques à cette Data Source.

* Dans notre exemple, nous pourrions par exemple demander à Terraform d'aller récupérer les informations sur le pod nginx
* Pour définir notre source de données nous pouvons maintenant dans notre code terraform, lui demander d'aller récupérer l'ID de l'AMI :
```
data "kubernetes_pod" "podnginx" {
  metadata {
    name = "terraform-example"
  }
}


```
* Vous récupérer alors les informations sur le podnginx


## Utiliser les données d'une source de données 

* Pour récupérer les données d'une Data source, on utilise la syntaxe de référence d'attribut suivante
```
data.<DATA_SOURCE_NAME.≶NAME>.<ATTRIBUTE>
```
* La liste des attributs récupérables est également disponible dans la [documentation officielle](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/pod#spec)
* Ici nous récupérons la liste des configmap via notre data source :
```
data "kubernetes_config_map" "example" {
  metadata {
    name = "my-config"
  }
}
```
* Puis nous utilisons le configmap dans notre deploiement
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
* Vous devez alors créer le configmap my-config soit avec kubectl soit en ajoutant la ressource aux fichiers terraform
* Pour appliquer notre modification, utiliser la commande : `terraform init && terraform apply`
* Puis retourner vérifier avec kubectl

## Suppression de la ressource
* Les exercices étant terminer, nous allon supprimer les ressources avec la commande 
```
terraform destroy
```
