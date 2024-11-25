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

  ## Variables

  ## Entrée / sortie

  
