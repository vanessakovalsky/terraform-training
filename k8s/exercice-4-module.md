# Exercice 4 - les modules

## Objectifs

Cet exercice a pour objectifs :
* d'apprendre à créer un module
* d'utiliser notre module dans nos fichiers terraform
* de créér un déploiement contenant wordpress et toutes les ressources associées


## Structure du module

* Notre module aura la structure suivante :
    * LICENSE : licence sous laquelle votre module sera distribué. Il informera les personnes qui l'utilisent des conditions dans lesquelles il a été mis à disposition.
    * README.md : contiendra de la documentation au format markdown décrivant comment utiliser votre module.
    * main.tf : contiendra le code principal de votre configuration Terraform de votre module.
    * variables.tf : contiendra les variables de votre module. Lorsque votre module est utilisé par d'autres, les variables seront configurées comme arguments dans le bloc module que nous verrons plus tard dans cet article.
    * outputs.tf : comme son nom l'indique, il contiendra les variables de sortie de votre module. Elles sont souvent utilisées pour transmettre des informations sur les parties de votre infrastructure définies par le module à d'autres parties de votre configuration.

* Créer un dossier `modules` et à l'intérieur un dossier `k8s-wordpress`
```
mkdir -p modules/k8s-wordpress
```

## Création du module

* Créer le fichier LICENCE et choisir votre licence pour le module, par exemple [Apache](https://www.apache.org/licenses/LICENSE-2.0) ou [GPL](https://www.gnu.org/licenses/gpl-3.0.html)
* Créer ensuite un fichier README.md qui contient la documentation suivante (que vous pouvez adapter si vous le souhaiter)
````
# K8S - Wordpress

Ce module provisionne les ressources nécessaires au déploiement d'un site Wordpress dans un cluster Kubernetes.

## Usage

```hcl
module "<module name>" {
    source = "path of your module"
    site_name = "<UNIQ SITE NAME>"
    tags = {
        key   = "<value>"
    }
}
```
Lorsque site est déployé vous pouvez vous connecter dessus et lancer l'installation de Wordpress
````

* A l'aide de la [documentation du provider kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) définir les ressources suivantes :
    * Service de type NodePort
    * PVC pour le stockage
    * Deploiement pour Wordpress
    * Deploiement pour MySQL
    * Secret pour le mot de passe mysql root, le mot de passe mysql pour Wordpress, le mot de passe pour l'utilisateur de Wordpress
    * Configmap pour les utilisateurs de db et de wordpress
* Il n'est pas nécessaire de définir un provider dans un module. En effet, le module étant importé dans un autre élément de configuration, le provider est hérité de la configuration parente.
* Créer un fichier `variables.tf` pour définir la variable de l'app et du namespace à utiliser dans le cluster
* Enfin afin de récupérer l'adresse du site, créer un fichier output qui récupère l'adresse IP du node depuis le service et le port exposé
* L'ensemble des éléments de notre modules est prêt, il ne reste plus qu'à l'utiliser

## Utiliser notre module

* Revenir au `main.tf` du module racine 
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
module "k8s_wordpress" {
    source = "./modules/k8s-wordpress"
    app_name = "devopssec-terraform"
    namepsace = "mynamespace
}
```
* Exécutons le code pour voir si tout est ok :
```
terraform init && terraform apply
```
* Après avoir répondu yes, vous devriez voir les lignes suivantes s'afficher :
```
@TOCOPY
```
* Votre wordpress est déployé, vous pouvez aller le voir via kubectl et l'afficher dans votre navigateur

## Suppression de la ressource
* Les exercices étant terminer, nous allon supprimer les ressources avec la commande 
```
terraform destroy
```

## Memo 

- Wordpress sur K8S : https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/ 