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
```
- Le bloc data "azurerm_resource_group" définit la data source.
- On indique le name du Resource Group existant.
- Ensuite, on peut utiliser data.azurerm_resource_group.existing_rg.<attribut> pour obtenir des attributs comme location ou id. 

3. Exemple avancé : Construire des ressources à partir d’une data source

Imaginons que vous avez un Virtual Network (VNet) déjà existant dans un Resource Group, et que vous voulez lancer une VM dans ce réseau sans recréer le VNet. Vous pouvez faire comme suit :
```
data "azurerm_resource_group" "existing_rg" {
  name = "nom-du-groupe-de-ressources-existant"
}

data "azurerm_virtual_network" "existing_vnet" {
  name                = "nom-du-vnet-existant"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

resource "azurerm_network_interface" "nic" {
  name                = "example-nic"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_virtual_network.existing_vnet.subnets[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "example-vm"
  resource_group_name   = data.azurerm_resource_group.existing_rg.name
  location              = data.azurerm_resource_group.existing_rg.location
  size                  = "Standard_F2"
  network_interface_ids = [azurerm_network_interface.nic.id]
  
  admin_username = "adminuser"
  admin_password = "MotDePasseSecurise123!"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
```
Explications :

- On interroge d’abord le Resource Group existant avec data.azurerm_resource_group.existing_rg.
- Puis on interroge le VNet existant avec data.azurerm_virtual_network.existing_vnet, en se basant sur le nom du VNet et le groupe de ressources. Ce pattern est courant pour réutiliser des parties de l’infrastructure sans les recréer. 
- Ensuite, on crée une interface réseau et une VM en se basant sur les valeurs récupérées.

4. Autres Data Sources utiles dans Azure

Voici quelques data sources pratiques que vous pouvez utiliser dans vos projets Terraform + Azure :

| Data Source	| Utilisation |
--------------------
| azurerm_resource_group | 	Interroger un groupe de ressources existant | 
| azurerm_virtual_network | Lire un VNet existant (adresse, sous-réseaux, etc.) | 
| azurerm_subscription | Récupérer des informations sur la souscription actuelle (ID, nom…) | 

5. Bonnes pratiques

Utiliser des data sources quand vous ne voulez pas gérer certaines ressources via Terraform, mais simplement les référencer.

Versionner vos fichiers Terraform même si vous utilisez des data sources, car les dépendances entre ressources peuvent évoluer.

Documenter clairement quelles ressources sont gérées par Terraform et lesquelles sont lu via des data sources.

6. Exercices pratiques

- Référencer un RG existant : Créez un data "azurerm_resource_group" pour un Resource Group Azure déjà existant, et affichez son id et son location avec des outputs Terraform.
- Réseau existant + VM : Supposez qu’un VNet existe déjà dans un groupe de ressources. Utilisez data "azurerm_virtual_network" pour le référencer. Créez une machine virtuelle qui utilise ce VNet (comme dans l’exemple avancé).
- Interroger un sous-réseau (subnet) : Utilisez data "azurerm_subnet" pour lire un sous-réseau spécifique dans un VNet existant. Puis créez un NIC (interface réseau) qui utilise ce sous-réseau.
- Utiliser azurerm_subscription : Ajoutez une data "azurerm_subscription" "current" pour obtenir l’ID de la souscription actuelle, et affichez-le avec un output. 

7. Commandes Terraform

- terraform init — initialiser la configuration
- terraform plan — voir le plan : devrait afficher 0 ressources à créer si vous utilisez uniquement des data sources et aucun resource … nouveau
- terraform apply — appliquer la configuration
- terraform destroy — détruire les ressources que vous avez créées dans cette configuration

8. Résumé

Les data sources sont un moyen puissant dans Terraform pour récupérer des informations sur des ressources Azure existantes sans les dupliquer. Elles facilitent la modularité, la collaboration entre projets Terraform, et la réutilisation d’infrastructures. En les maîtrisant, vous devenez capable de créer des configurations Terraform plus flexibles et respectueuses des ressources déjà déployées.
