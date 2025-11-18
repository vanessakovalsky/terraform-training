# Exercice 1 - Configurer un provider et créer une première ressource

## Prérequis

-   Pour pouvoir déployer sur Azure, vous avez besoin d'un abonnement
    Azure.
-   Vous devez également [installer Azure
    CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
    et configurer la connexion avec la commande `az login`.

## Configurer le provider

-   Commençons par configurer le provider que vous souhaitez utiliser.
    Créez un fichier nommé **azure.tf** puis ajoutez le code suivant (en
    l'adaptant avec vos informations d'accès) :
```
    terraform {
        required_providers {
            azurerm = {
                source = "hashicorp/azurerm"
                version = "=3.0.1"
            }
        }
    }

    provider "azurerm" {
        features  {}
    }
```
-   Nous indiquons à Terraform différentes informations :
    -   le provider avec le label `azurerm`
    -   le bloc `features` est obligatoire pour le provider Azure

## Ajouter une ressource

-   Chaque provider propose différents types de ressources.
-   Commençons avec une ressource simple, un **resource group**.
-   Ajoutez le code suivant dans votre fichier **azure.tf** :


```
    resource "azurerm_resource_group" "demo" {
        name = "demo-resources"
        location = "West Europe"
    }
```
-   La syntaxe générale d'une ressource Terraform est la suivante :

```
    resource "<PROVIDER>_<TYPE>" "<NAME>" {
        [CONFIG …]
    }
```
-   **PROVIDER** : le nom du provider (ici `azurerm`)\
-   **TYPE** : le type de ressource à créer dans ce provider (ici c'est
    un namespace)\
-   **NAME** : un identifiant utilisable dans votre code Terraform pour
    référencer cette ressource (ici `demo`)\
-   **CONFIG** : un ou plusieurs arguments spécifiques à cette ressource

## Lancer le déploiement

-   Pour démarrer notre déploiement, ouvrez un terminal et placez-vous
    dans le dossier contenant votre fichier **main.tf**.
-   Exécutez ensuite :

```
    terraform init
```
-   Vous obtenez un résultat similaire à :

```
    Initializing the backend...
    Initializing provider plugins...
    ...
    Terraform has been successfully initialized!
```
-   Un fichier caché `.terraform` apparaît alors dans votre dossier.
-   Maintenant, demandez à Terraform de créer le plan d'exécution :

```
    terraform plan
```
-   Exemple de résultat :


```
    Terraform used the selected providers to generate the following execution plan.
      + create
    ...
    Plan: 1 to add, 0 to change, 0 to destroy.
```
-   Les symboles indiquent :
    -   `+` ressources ajoutées
    -   `-` ressources supprimées
    -   `~` ressources modifiées
-   Enfin, exécutez le plan avec :

```
    terraform apply
```
-   Exemple de sortie :

```
    Do you want to perform these actions?
    Enter a value: yes
    ...
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
## Vérification du déploiement

-   Vous pouvez vérifier via le portail Azure que le resource group a
    bien été créé :
-   Accédez à https://portal.azure.com/
-   Allez dans **Resource Groups** et vérifiez la présence de votre
    ressource.

## Ajouter une machine virtuelle à notre fichier Terraform

Ajoutez les ressources suivantes dans **main.tf** :
```
    resource "azurerm_virtual_network" "example" {
      name                = "example-network"
      address_space       = ["10.0.0.0/16"]
      location            = azurerm_resource_group.example.location
      resource_group_name = azurerm_resource_group.example.name
    }

    resource "azurerm_subnet" "example" {
      name                 = "internal"
      resource_group_name  = azurerm_resource_group.example.name
      virtual_network_name = azurerm_virtual_network.example.name
      address_prefixes     = ["10.0.2.0/24"]
    }

    resource "azurerm_network_interface" "example" {
      name                = "example-nic"
      location            = azurerm_resource_group.example.location
      resource_group_name = azurerm_resource_group.example.name

      ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.example.id
        private_ip_address_allocation = "Dynamic"
      }
    }

    resource "azurerm_linux_virtual_machine" "example" {
      name                = "example-machine"
      resource_group_name = azurerm_resource_group.example.name
      location            = azurerm_resource_group.example.location
      size                = "Standard_F2"
      admin_username      = "adminuser"
      network_interface_ids = [
        azurerm_network_interface.example.id,
      ]

      admin_ssh_key {
        username   = "adminuser"
        public_key = file("~/.ssh/id_rsa.pub")
      }

      os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }

      source_image_reference {
       publisher = "West Europe"
       offer = "Canonical"
       sku = "0001-com-ubuntu-server-jammy"
       version = "22_04-lts"
      }
    }
```
-   Nous avons ici ajouté une machine virtuelle Linux ainsi que toutes
    ses dépendances (réseau, subnet, interface).

-   Ce déploiement créera une machine virtuelle Ubuntu et les ressources
    associées.

-   Assurez-vous d'avoir une clé SSH publique au chemin indiqué, sinon
    modifiez le chemin ou générez une clé.

-   Lancez le déploiement :

```
    terraform init && terraform apply
```
## Supprimer les ressources

-   Pour supprimer les ressources créées :
```
    terraform destroy
```
