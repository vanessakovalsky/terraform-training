# Exercice 3 — Utiliser des *Data Sources* avec Terraform et Azure

## Objectifs

- Comprendre ce qu’est une *data source* dans Terraform  
- Savoir interroger des ressources Azure existantes via des data sources  
- Utiliser les données récupérées pour configurer de nouvelles ressources Terraform  
- Gérer des cas où une partie de l’infrastructure n’est pas gérée dans le même projet Terraform

---

## Prérequis

- Avoir un environnement Terraform + Azure (provider `azurerm`) déjà configuré  
- Avoir au moins une ressource Azure existante (par exemple un **Resource Group** ou un **Virtual Network**) que l’on va interroger  
- Connaissance de base des fichiers `.tf` (main.tf, variables.tf, …)

---

## 1. Introduction aux *Data Sources*

Une *data source* (source de données) dans Terraform vous permet de **lire les informations d’une ressource Azure qui existe déjà**, sans la recréer. C’est très utile quand :

- La ressource a été créée par un autre projet Terraform  
- Elle a été créée manuellement dans le portail Azure  
- Vous devez la référencer dans vos ressources Terraform

Par exemple, la *data source* `azurerm_resource_group` permet de récupérer les propriétés d’un **Resource Group** existant. :contentReference[oaicite:0]{index=0}

---

## 2. Exemple basique : Interroger un Resource Group

Dans votre **main.tf**, ajoutez une déclaration de data source :

```hcl
data "azurerm_resource_group" "existing_rg" {
  name = "nom-du-groupe-de-ressources-existant"
}

output "existing_rg_location" {
  value = data.azurerm_resource_group.existing_rg.location
}

output "existing_rg_id" {
  value = data.azurerm_resource_group.existing_rg.id
}
