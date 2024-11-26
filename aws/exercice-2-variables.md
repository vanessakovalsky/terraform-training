# Exercice 2 - Les variables input et output

## Objectifs

Cet exercice a pour objectifs : 
* De créer et d'utiliser des variables d'entrées
* De créer et d'utiliser des variables de sorties


## Input Variables

### Déclarer une variable d'entrée
* Les variables sont composées d'un nom, d'un type, d'une valeur par défaut et d'une description. Seul le nom est obligatoire.
* Pour déclarer une variable on utilise un bloc de type `variable` et son label est alors le nom de notre variable
```
variable "AWS_REGION" {
    type = string
    default = "us-east-2"
    description = "Région de notre instance ec2"
}
```

### Accéder à une variable d'entrée
* Pour accéder à une variable on peut utilisé la variable en préfixant son nom du mot-clé `var.`
```
provider "aws" {
    region = var.AWS_REGION
}
```
* Une autre syntaxe est possible en entourant le nom `var.AWS_REGION` d'accolades et en les faisant précéder d'un symbole $. Cette deuxième syntaxe est obligatoire si vous devez concaténer la valeur de plusieurs variables:
```
provider "aws" {
    region = "${var.AWS_REGION}"
}
```

### Définir la valeur d'une variable

* Il est possible de définir la valeur d'une variable de différentes manières :
    * en utilisant l'option -var 'NOMDELABARIABLE=valeur' lors de la commande terraform apply
    * en utilisant un fichier (celui ci aura alors l'extenations .tfvars) et en appelant ce fichier avec la commande `terraform apply -var-file="aws-access.tfvars`
    * en utilisant le mode interractif, si les variables ne sont pas spécifiées, terraform vous demande alors de saisir les valeurs de manière interractive. /!\ Dans ce cas là les valeurs ne sont pas enregistrées.

## Output Variables 

* Les variables de sorties permettent de récupérérer des informations sur son infrastructure comme un identifiant ou une adresse IP par exemple.
* On utilise alors un bloc de type `output` et on définit ce qui doit être contenu dans cette variables. Les valeurs possibles dépendent alors de la ressource créé
```
output "public_ip" {
    value = aws_instance.my_ec2_instance.public_ip
}
```

## Exercice d'application sur notre projet :

* Créer un fichier vars.tf qui contiendra la définition des 5 variables suivantes : 
    * AWS ACCESS KEY
    * AWS SECRET KEY
    * AWS REGIONS
    * AWS AMI 
    * Chemin vers la clé SSH publique qui doit être déployée sur l'instance
* Dans le fichier main.tf, remplacer les valeurs en dur par un appel à ses variables et ajouter la clé SSH
* Créer un fichier terraform.tfvars qui contiendra les pairs clé/valeurs de nos variables
* Définir une variable de sortie qui renvoit l'adresse IP de l'instance EC2 
* Appliquer vos modifications avec la commande `terraform init && terraform apply`
* Utiliser l'adresse IP retourné pour vérifier si votre déploiement fonctionne toujours
* Vérifier alors l'applications de vos variables est correcte dans la console Web AWS
* Essayer de vous connecter sur votre instance avec la clé ssh privé que vous avez généré à l'étape de configuration

## Suppression de la ressource
* Les exercices étant terminer, nous allon supprimer les ressources avec la commande 
```
terraform destroy
```
