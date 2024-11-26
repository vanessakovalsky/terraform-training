# Exercice 6 - Gérer l'état de notre infrastructure

## Objectifs
Cet exercice a pour objectif
* De comprendre le fichier d'état de Terraform
* De pouvoir enregistrer et utiliser le fichier d'état dans un stockage distant

## Pré-requis
* Avoir un terraform installé
* Avoir initialisé une connexion vers un fournisseur Cloud

## Un Exemple Détaillé

Pour illustrer le rôle important des fichiers d’état dans Terraform, prenons l’exemple d’un projet de déploiement d’une infrastructure cloud simple. Supposons que vous ayez à configurer un serveur virtuel sur AWS, avec un groupe de sécurité associé et un équilibrage de charge.

### Création et Gestion du Fichier d’État

Lorsque vous exécutez terraform apply pour la première fois, Terraform crée un fichier d’état nommé terraform.tfstate. 
Ce fichier enregistre des détails clés sur les ressources créées, comme les identifiants AWS, les adresses IP et les configurations de sécurité.

* Configuration Initiale : Votre fichier Terraform définit un serveur EC2, un groupe de sécurité et un équilibrage de charge.
* Première Exécution : Terraform déploie ces ressources et enregistre leurs états dans terraform.tfstate.
* Consultation du Fichier d’État : Ce fichier contient maintenant des informations telles que l’ID de l’instance EC2, les règles du groupe de sécurité et les détails de l’équilibrage de charge.

### Modifications et Mises à Jour

Supposons maintenant que vous modifiez la configuration pour augmenter la capacité de l’équilibrage de charge.

* Mise à Jour de la Configuration : Vous ajustez le paramètre de capacité dans votre fichier Terraform
* Deuxième Exécution : Lorsque vous exécutez à nouveau terraform apply, Terraform compare l’état souhaité (votre configuration mise à jour) avec l’état actuel (stocké dans terraform.tfstate).
* Application Sélective des Changements : Terraform détecte que seul l’équilibrage de charge doit être modifié et applique les changements nécessaires sans toucher aux autres ressources.

## Modifier le backend de stockage du fichier d'état

Le fichier d'état par défaut est stocker en local dans le dossier courant.
Il est possible de définir un backend de stockage différent pour notre fichier d'état. https://developer.hashicorp.com/terraform/language/backend 

* Ici nous allons utiliser le backend s3 qui est un espace de stockage AWS
* Pour cela dans notre configuration de terraform nous définissons les élements suivants (à ajouter à votre fichier définissant le projet) :
```
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "europe-west-9"
    dynamodb_table = "terraform_state"
  }
}
```
* Vous pouvez créer ces ressources à l'aide des ressources terraform suivantes :
```
resource "aws_s3_bucket" "bucket" {
    bucket = "terraform-state-backend"
    versioning {
        enabled = true
    }
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
    object_lock_configuration {
        object_lock_enabled = "Enabled"
    }
    tags = {
        Name = "S3 Remote Terraform State Store"
    }
}

resource "aws_dynamodb_table" "terraform-lock" {
    name           = "terraform_state"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        "Name" = "DynamoDB Terraform State Lock Table"
    }
}
```

* Une fois les ressources crée et la commande terraform apply passé, votre fichier d'état est alors stocké dans le stockage s3.
* Pour synchroniser en local votre fichier depuis le serveur distant utilisé la commende : terraform state pull
* Pour envoyer votre fichier d'état local sur le backend utilisé la commande : terraform state push
* Cela permet non seulement de sauvegarder votre fichier, mais aussi de partager votre fichier d'état entre plusieurs utilisateurs. 

## Pour en savoir plus 

https://blog.stephane-robert.info/docs/infra-as-code/provisionnement/terraform/gestion-state/
