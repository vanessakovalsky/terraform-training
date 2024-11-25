# Openstack - exercice 1 - Configurer le provider

## Pré-requis
* Afin de pouvoir utiliser un fournisseur, vous devez avoir un compte chez celui et les informations de connexion à ce compte
* De plus le compte que vous utilisez doit avoir les droits de créer la ressource que Terraform va crée

## Configuration du provider

* Commençons par configurer le provider (fournisseur) que vous souhaitez utiliser.
* Créer un fichier nommé main.tf dans visualstudiocode 
* Ensuite, mettre le code suivant (en adaptant avec vos informations d'accès):
```
# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "pwd"
  auth_url    = "http://myauthurl:5000/v3"
  region      = "RegionOne"
}
```
* Nous indiquons à Terrform différente information :
    - le provider avec le label "openstack'
    - la region dans laquelle nos ressources seront créé 
    - nos informations d'accès (pour l'instant ce n'est pas très sécurisé, nous sécuriserons cela plus tard lors d'un autre exercice)


## Ajout de la ressource

* Chaque fournisseur propose différents types de ressources. 
* Commençons par une ressource simple, un volume de stockage
* Ajouter le code suivant à votre fichier main.tf :
```
resource "openstack_blockstorage_volume_v3" "myvol" {
  name = "myvol"
  size = 1
}
```
* La syntaxe générale d'une ressource Terraform est la suivante :
```
resource "<FOURNISSEUR>_<TYPE>" "<NOM>" {
    [CONFIG …]
}
```
    * FOURNISSEUR : c'est le nom d'un fournisseur (ici le provider "aws").
    * TYPE : c'est le type de ressources à créer dans ce fournisseur (ici c'est un openstack_blockstorage_volume_v3)
    * NOM : c'est un identifiant que vous pouvez utiliser dans le code Terraform pour faire référence à cette ressource (ici "myvol")
    * CONFIG : se compose de un ou plusieurs arguments spécifiques à cette ressource, dans notre cas :
        * name : le nom du volume
        * size : taille du volume.


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
- Checking for available provider plugins...
- Downloading plugin for provider "openstack" (hashicorp/openstack) 2.57.0...
...
...
Terraform has been successfully initialized!
```
* Un nouveau fichier caché .terraform est alors apparu dans votre dossier
* Demander maintenant à terraform de créer le plan d'éxecution, qui détermine les actions nécessaires pour atteindre l'état souhaité dans votre fichier main.tf . 
* Pour cela exécuter la commande
```
terraform plan
```
* Qui donne un résultat similaire à :
```
Refreshing Terraform state in-memory prior to plan...
...
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.my_ec2_instance will be created
  + resource "aws_instance" "my_ec2_instance" {
      + ami                          = "ami-07c1207a9d40bc3bd"
      +  ...
      +  ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.
"terraform apply" is subsequently run
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
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.my_ec2_instance: Creating...
aws_instance.my_ec2_instance: Still creating... [10s elapsed]
aws_instance.my_ec2_instance: Still creating... [20s elapsed]
aws_instance.my_ec2_instance: Still creating... [30s elapsed]
aws_instance.my_ec2_instance: Creation complete after 39s [id=i-0f6d6ee734f745e22]
```

## Vérification du déploiement 

* Vous pouvez ouvrir la console web Openstack pour vérifier que votre instance est bien crée




## Suppression de la ressource
* Les exercices étant terminer, nous allons supprimer les ressources avec la commande 
```
terraform destroy
```
* Qui donnera un résultat similaire à :
```
Terraform will perform the following actions:

  # aws_instance.my_ec2_instance will be destroyed
  - resource "aws_instance" "my_ec2_instance" {
        ...
    }

  # aws_security_group.instance_sg will be destroyed
  - resource "aws_security_group" "instance_sg" {
        ...
    }

  Enter a value: yes

aws_instance.my_ec2_instance: Destroying... [id=i-0b25fb9f0b17211e7]
aws_instance.my_ec2_instance: Still destroying... [id=i-0b25fb9f0b17211e7, 10s elapsed]
aws_instance.my_ec2_instance: Still destroying... [id=i-0b25fb9f0b17211e7, 20s elapsed]
aws_instance.my_ec2_instance: Destruction complete after 22s
aws_security_group.instance_sg: Destroying... [id=sg-07e6921e0c5dc4ca4]
aws_security_group.instance_sg: Destruction complete after 2s

Destroy complete! Resources: 2 destroyed.
```
