# Exercice 4 - les modules

## Objectifs

Cet exercice a pour objectifs :
* d'apprendre à créer un module
* d'utiliser notre module dans nos fichiers terraform

## Objectifs de notre module

Notre module va nous permettre les actions suivantes :
* Création d'un bucket S3 sur AWS
* Activation de l'hébergement de site web
* Définition des autorisations
* Création e ajout d'un document index

## Structure du module

* Notre module aura la structure suivante :
    * LICENSE : licence sous laquelle votre module sera distribué. Il informera les personnes qui l'utilisent des conditions dans lesquelles il a été mis à disposition.
    * README.md : contiendra de la documentation au format markdown décrivant comment utiliser votre module.
    * main.tf : contiendra le code principal de votre configuration Terraform de votre module.
    * variables.tf : contiendra les variables de votre module. Lorsque votre module est utilisé par d'autres, les variables seront configurées comme arguments dans le bloc module que nous verrons plus tard dans cet article.
    * outputs.tf : comme son nom l'indique, il contiendra les variables de sortie de votre module. Elles sont souvent utilisées pour transmettre des informations sur les parties de votre infrastructure définies par le module à d'autres parties de votre configuration.

* Créer un dossier `modules` et à l'intérieur un dossier `aws-s3-static-website-bucket`
```
mkdir -p modules/aws-s3-static-website-bucket
```

## Création du module

* Créer le fichier LICENCE et choisir votre licence pour le module, par exemple [Apache](https://www.apache.org/licenses/LICENSE-2.0) ou [GPL](https://www.gnu.org/licenses/gpl-3.0.html)
* Créer ensuite un fichier README.md qui contient la documentation suivante (que vous pouvez adapter si vous le souhaiter)
````
# AWS S3 static website bucket

Ce module provisionne un bucket S3 configuré pour l'hébergement d'un site web statique.

## Usage

```hcl
module "<module name>" {
    source = "path of your module"
    bucket_name = "<UNIQ BUCKET NAME>"
    tags = {
        key   = "<value>"
    }
}
```
Lorsque votre bucket est créé, envoyer un fichier `index.html` et un fichier `error.html` dans votre bucket. 
````

* Nous allons maintenant créer la configuration du bucket
* Pour cela nous commençons dans le fichier main.tf ui va contenir une ressource aws_s3_bucket.
* Cette ressource utilisera les argument suivants : 
    * bucket : nom unique du bucket
    * acl : Access Control lists (ACL) qui permet de gérer l'accès aux buckets et à ses objets
    * policy : le contenu en json de la police du bucet qui permet de sépcifier les conditions d'actions autorisées ou refusées du bucket S3
    * website : activation de l'hébergement statique avec les arguments suivants :
        * index_document : fichier index.html à utiliser lorsque les demandes arrives sur le endpoint S3
        * error_document : fichier d'erreur html à retourner en cas d'erreur avec un code 4XX

* Créer le fichier main.tf et mettre le contenu suivant à l'intérieur :
```
resource "aws_s3_bucket" "s3_bucket" {
    bucket = var.bucket_name
    acl    = "public-read"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*"
            ]
        }
    ]
}
EOF

    website {
        index_document = "index.html"
        error_document = "error.html"
    }
}
```
* Il n'est pas nécessaire de définir un provider dans un module. En effet, le module étant importé dans un autre élément de configuration, le provider est hérité de la configuration parente.
* Créer un fichier `variables.tf` pour définir la variable du nom du bucket et mettre le contenu suivant :
```
variable "bucket_name" {
    description = "Name of the s3 bucket. Must be unique."
    type = string
}
```
* Enfin afin de récupérer l'adresse du site et l'identifiant du bucket nous créons un fichier `outputs.tf` avec le contenu suivant :
```
output "website_endpoint" {
    description = "Domain name of the bucket"
    value       = aws_s3_bucket.s3_bucket.website_endpoint
}

output "name" {
    description = "Name (id) of the bucket"
    value       = aws_s3_bucket.s3_bucket.id
}
```
* L'ensemble des éléments de notre modules est prêt, il ne reste plus qu'à l'utiliser

## Utiliser notre module

* Revenir au `main.tf` du module racine (celui qui contient le provider et la création de notre instance ec2)
* La symtaxe d'utilisation d'un module est la suivante : 
```
module "<NAME>" { 
    source = "<SOURCE>" 
    [ARGUMENTS ...] 
  }
```
    NAME : identifiant que l'on peut utiliser dans le code terraform pour faire référence à notre module
    source : chemin relatif de notre module
    ARGUMENTS : variables d'entrée spécifique de notre module

* Ajouter à la fin du fichier `main.tf` le code suivant

```
module "website_s3_bucket" {
    source = "./modules/aws-s3-static-website-bucket"
    bucket_name = "devopssec-terraform"
}
```
* Enfin il est nécessaire pour récupérer les variables de sortie du module, de les déclarer dans le fichier racine `outputs.tf` : 
```
output "website_bucket_name" {
    description = "Name (id) of the bucket"
    value       = module.website_s3_bucket.name
}
  
output "website_endpoint" {
    description = "Domain name of the bucket"
    value       = module.website_s3_bucket.website_endpoint
}
```
* Ajouter dans le fichier de variable la variable avec le nom de votre bucket (qui doit être unique)
* Exécutons le code pour voir si tout est ok :
```
terraform init && terraform apply
```
* Après avoir répondu yes, vous devriez voir les lignes suivantes s'afficher :
```
Enter a value: yes

module.website_s3_bucket.aws_s3_bucket.s3_bucket: Creating...
module.website_s3_bucket.aws_s3_bucket.s3_bucket: Still creating... [10s elapsed]
module.website_s3_bucket.aws_s3_bucket.s3_bucket: Creation complete after 12s [id=devopssec-terraform]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

website_bucket_name = devopssec-terraform
website_endpoint = devopssec-terraform.s3-website-us-east-1.amazonaws.com
```
* Votre bucket est crée et configuré, vous pouvez aller le voir dans la console web de AWS

## Envoi d'un fichier web et affichage

* Afin d'aller au bout nous allons créer un fichier `index.html` avec le contenu suivant :
```
<html>
<body>
<h1>Bienvenue sur votre site</h1>
</body>
</html>
```
* Ainsi qu'un fichier `error.html` avec le contenu suivant
```
<html>
<body>
<h1>Erreur : la page que vous demandez n'est pas disponible</h1>
</body>
</html>
```
* Ensuite nous allons envoyer ces deux fichiers sur votre bucket en utilisant la variable de sortie de terraform via AWS cli :
```
aws s3 cp index.html s3://$(terraform output website_bucket_name)/
aws s3 cp error.html s3://$(terraform output website_bucket_name)/
```
* Cela devrait afficher un message de type :
```
upload: index.html to s3://vanessa-terraform/error.html       
upload: erreur.html to s3://vanessa-terraform/index.html 
```
* Pour récupérer le endpoint de votre bucket, demandons à terraform de nous l'afficher
```
terraform output website_endpoint
```
* Qui affiche comme résultat le endpoint de votre site :
```
vanessa-terraform.s3-website-us-east-1.amazonaws.com
```
* Ouvrir un navigateur et coller l'adresse récupérer, vous aurez alors un message `Bienvenue sur votre site`
* Ajouter à l'adresse '/toto'  pour voir afficher le message d'erreur 

## Suppression de la ressource
* Les exercices étant terminer, nous allon supprimer les ressources avec la commande 
```
terraform destroy
```
