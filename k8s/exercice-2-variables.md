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
variable "name" {
  type        = string
  description = "(Required) Name of the deployment"
}
```

### Accéder à une variable d'entrée
* Pour accéder à une variable on peut utilisé la variable en préfixant son nom du mot-clé `var.`
```
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = var.name
...
```
* Une autre syntaxe est possible en entourant le nom `var.name` d'accolades et en les faisant précéder d'un symbole $. Cette deuxième syntaxe est obligatoire si vous devez concaténer la valeur de plusieurs variables:
```
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "${var.name}"
...
```

### Définir la valeur d'une variable

* Il est possible de définir la valeur d'une variable de différentes manières :
    * en utilisant l'option -var 'NOMDELABARIABLE=valeur' lors de la commande terraform apply
    * en utilisant un fichier (celui ci aura alors l'extenations .tfvars) et en appelant ce fichier avec la commande `terraform apply -var-file="k8s.tfvars`
    * en utilisant le mode interractif, si les variables ne sont pas spécifiées, terraform vous demande alors de saisir les valeurs de manière interractive. /!\ Dans ce cas là les valeurs ne sont pas enregistrées.

## Output Variables 

* Les variables de sorties permettent de récupérérer des informations sur son infrastructure comme un identifiant ou une adresse IP par exemple.
* On utilise alors un bloc de type `output` et on définit ce qui doit être contenu dans cette variables. Les valeurs possibles dépendent alors de la ressource créé
```
output "port" {
  value = "${kubernetes_service.nginxsvc.spec.0.port.0.port}"
}
```

## Exercice d'application sur notre projet :

* Créer un fichier vars.tf qui contiendra la définition des 5 variables suivantes : 
    * name : nom du déploiement
    * app_name : nom de l'application
    * namespace : nom du namespace à créer et à utiliser
    * image : identifiant et version de l'image à utiliser
    * port : port à exposer dans le service
* Dans le fichier k8s.tf, remplacer les valeurs en dur par un appel à ses variables 
* Créer un fichier terraform.tfvars qui contiendra les pairs clé/valeurs de nos variables

* Définir une variable de sortie qui renvoit l'adresse IP du node port 
* Appliquer vos modifications avec la commande `terraform init && terraform apply`
* Utiliser l'adresse IP retourné pour vérifier si votre déploiement fonctionne toujours
* Vérifier alors l'applications de vos variables est correcte dans kubectl


## Suppression de la ressource
* Les exercices étant terminer, nous allon supprimer les ressources avec la commande 
```
terraform destroy
```
