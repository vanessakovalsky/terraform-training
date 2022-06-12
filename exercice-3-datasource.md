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

* Dans notre exemple, nous pourrions par exemple demander à Terraform d'aller récupérer l'ID de l'AMI pour l'instance depuis les API de AWS. 
* Pour cela nous avons besoin de récupérer l'ID du propriétaire de notre image, nous pouvons l'obtenir soit dans la console web soit avec la commande `aws ec2 describe-images --image-ids ami-085925f297f89fce1 --region us-east-1` qui nous renvoit un résultat similaire à :
```
{
    "Images": [
        {
            "VirtualizationType": "hvm", 
            "Description": "Canonical, Ubuntu, 18.04 LTS, amd64 bionic image build on 2020-04-08",
            ...
            "ImageId": "ami-085925f297f89fce1", 
            ...
            "RootDeviceType": "ebs", 
            "OwnerId": "099720109477", 
            "Name": "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200408"
        }
    ]
}
```
* Dans ce résultat nous récupérons l'identifiant du propriétaire qui est la valeur du champ OwnerId 
* Pour définir notre source de données nous pouvons maintenant dans notre code terraform, lui demander d'aller récupérer l'ID de l'AMI :
```
data "aws_ami" "ubuntu-ami" {
    most_recent = true
    owners = ["099720109477"] # Canonical
}
```
* Vous récupérer alors l'identifiant de l'AMI la plus récente de Canonical

## Filtrer ses sources de données

* Si l'on souhaite récupérer une image différente, il est possible de filtrer également les sources de données avec l'argument filter qui prend alors un nom et des valeurs. 
* Pour connaitres les proporiétés à filtrer, il faut consulter la documentation officielle. Par exemple pour la data source AMI : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami  
* Ici nous filtrons sur le nom d'e l'image pour récupérer une image plus ancienne que l'on est sûr d'être compatible avec ce que l'on veut faire :
```
data "aws_ami" "ubuntu-ami" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200408"]
    }

    owners = ["099720109477"] # Canonical
}
```

## Utiliser les données d'une source de données 

* Pour récupérer les données d'une Data source, on utilise la syntaxe de référence d'attribut suivante
```
data.<DATA_SOURCE_NAME.≶NAME>.<ATTRIBUTE>
```
* La liste des attributs récupérables est également disponible dans la documentation officielle
* Ici nous récupérons l'ID de l'AMI via notre data source :
```
provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "ubuntu-ami" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200408"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_instance" "my_ec2_instance" {
    ami = data.aws_ami.ubuntu-ami.id
    instance_type = "t2.micro"
}
```
* Pour appliquer notre modification, utiliser la commande : `terraform init && terraform apply`
* Puis retourner vérifier dans la console web l'AMI utilisé par votre instance

## Suppression de la ressource
* Les exercices étant terminer, nous allon supprimer les ressources avec la commande 
```
terraform destroy
```