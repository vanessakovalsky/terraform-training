# Création d'une infrastructure avec Openstack

## Objectifs

Cet exercice a pour objectifs : 
- De savoir créer un infrastructure sur OpenStack avec terraform, composée de :
  - un réseau
  - un volume
  - une instance
 
## Pré-requis

- Avoir un environnement Openstack disponible et un compte avec les droits d'accès permettant la création
- Avoir configurer le provider openstack sur Terraform

## Création des ressources

- Pour créer la machine virtuelle, voici le code que vous pouvez ajouter dans votre fichier main.tf :
```
resource "openstack_compute_instance_v2" "terraform-demo-instance" {
  name = "demo-instance"
  image_id = "c786deab-3fc6-4a92-9a1e-54bcab32e2c2"
  flavor_id = "m1.small"
  key_pair = "demo-key"
  security_groups = ["default"]

  network {
    name = "Private"
  }
}
```
* A l'aide de la documentation : https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs , ajouter les ressources suivantes :
* * le réseau
  * la clé ssh
* Une fois les ajouts terminé, lancer la commande `terraform apply` pour déployer vos ressources et vérifier sur openstack si celle ci ont bien été créé

 ## Input Variables

### Déclarer une variable d'entrée
* Les variables sont composées d'un nom, d'un type, d'une valeur par défaut et d'une description. Seul le nom est obligatoire.
* Pour déclarer une variable on utilise un bloc de type `variable` et son label est alors le nom de notre variable
```
variable "OPENSTACK_REGION" {
    type = "string"
    default = "RegionOne"
    description = "Région de notre instance"
}
```

### Accéder à une variable d'entrée
* Pour accéder à une variable on peut utilisé la variable en préfixant son nom du mot-clé `var.`
```
provider "openstack" {
    region = var.OPENSTACK_REGION
}
```
* Une autre syntaxe est possible en entourant le nom `var.OPENSTACK_REGION` d'accolades et en les faisant précéder d'un symbole $. Cette deuxième syntaxe est obligatoire si vous devez concaténer la valeur de plusieurs variables:
```
provider "openstack" {
    region = "${var.OPENSTACK_REGION}"
}
```

### Définir la valeur d'une variable

* Il est possible de définir la valeur d'une variable de différentes manières :
    * en utilisant l'option -var 'NOMDELABARIABLE=valeur' lors de la commande terraform apply
    * en utilisant un fichier (celui ci aura alors l'extenations .tfvars) et en appelant ce fichier avec la commande `terraform apply -var-file="openstack-access.tfvars`
    * en utilisant le mode interractif, si les variables ne sont pas spécifiées, terraform vous demande alors de saisir les valeurs de manière interractive. /!\ Dans ce cas là les valeurs ne sont pas enregistrées.

## Output Variables 

* Les variables de sorties permettent de récupérérer des informations sur son infrastructure comme un identifiant ou une adresse IP par exemple.
* On utilise alors un bloc de type `output` et on définit ce qui doit être contenu dans cette variables. Les valeurs possibles dépendent alors de la ressource créé
```
output "public_ip" {
    value = openstack_compute_instance_v2.terraform-demo-instance.access_ip_v4
}
```

## Exercice d'application sur notre projet :

* Créer un fichier vars.tf qui contiendra la définition des 5 variables suivantes : 
    * Opensack username
    * Openstack password
    * Openstack region
    * Openstack keyname
* Dans le fichier main.tf, remplacer les valeurs en dur par un appel à ses variables et ajouter la clé SSH
* Créer un fichier terraform.tfvars qui contiendra les pairs clé/valeurs de nos variables
* Définir une variable de sortie qui renvoit l'adresse IP de l'instance
* Appliquer vos modifications avec la commande `terraform init && terraform apply`
* Utiliser l'adresse IP retourné pour vérifier si votre déploiement fonctionne toujours
* Vérifier alors l'applications de vos variables est correcte dans la console Web 
* Essayer de vous connecter sur votre instance avec la clé ssh privé que vous avez généré à l'étape de configuration

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

* Ajouter une source de données qui va chercher le type d'instance le plus petit qui est compatible avec l'image la plus récente et qui correspond à l'architecture x86_64

## Suppression de la ressource
* Les exercices étant terminer, nous allon supprimer les ressources avec la commande 
```
terraform destroy
```

  
