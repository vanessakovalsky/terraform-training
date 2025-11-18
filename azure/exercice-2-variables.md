# Exercice 2 --- Utiliser les variables avec Terraform et Azure

## Objectifs

-   Comprendre le rôle des variables dans Terraform\
-   Déclarer des variables dans `variables.tf`\
-   Utiliser des fichiers `.tfvars`\
-   Manipuler des variables sensibles\
-   Implémenter les variables dans un déploiement Azure

## Pré-requis

-   Terraform installé\
-   Azure CLI configuré (`az login`)\
-   Un abonnement Azure\
-   Un projet Terraform initial (provider + première ressource)

## 1. Déclarer des variables

Créez un fichier **variables.tf** :

``` hcl
variable "resource_group_name" {
  description = "Nom du groupe de ressources Azure"
  type        = string
  default     = "demo-rg"
}

variable "location" {
  description = "Région Azure pour les ressources"
  type        = string
  default     = "West Europe"
}

variable "vm_size" {
  description = "Taille de la machine virtuelle Azure"
  type        = string
  default     = "Standard_F2"
}

variable "admin_username" {
  description = "Nom d'utilisateur administrateur de la VM"
  type        = string
}

variable "admin_password" {
  description = "Mot de passe administrateur de la VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé SSH publique"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
```

## 2. Fournir des valeurs via des fichiers `.tfvars`

Créez un fichier **terraform.tfvars** :

``` hcl
resource_group_name = "prod-resources"
location            = "North Europe"
vm_size             = "Standard_D2s_v3"
admin_username      = "azureadmin"
ssh_public_key_path = "/home/user/.ssh/id_rsa.pub"
```

Pour les valeurs sensibles, utilisez un fichier séparé, par exemple
**secrets.auto.tfvars** :

``` hcl
admin_password = "MotDePasseTrèsSécurisé123!"
```

## 3. Utiliser les variables dans `main.tf`

``` hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
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

## 4. Validation et contraintes de variables

``` hcl
variable "location" {
  description = "Région Azure pour les ressources"
  type        = string
  default     = "West Europe"

  validation {
    condition     = contains(["West Europe", "North Europe", "East US"], var.location)
    error_message = "La région doit être West Europe, North Europe ou East US."
  }
}
```

## 5. Ordre de priorité des variables

1.  `terraform apply -var="name=value"`\
2.  `-var-file="fichier.tfvars"`\
3.  Fichiers auto-chargés (`*.auto.tfvars`)\
4.  Variables d'environnement (`TF_VAR_<nom>`)\
5.  Valeurs par défaut dans `variables.tf`

## 6. Exercices pratiques

### Exercice 1

Créer un fichier `dev.tfvars` avec un resource group nommé
`dev-demo-rg`.

### Exercice 2

Ajouter une variable `tags` de type `map(string)` et l'utiliser dans
toutes les ressources Azure.

### Exercice 3

Déclarer une variable sensible `admin_password` sans valeur par défaut,
puis la passer via :

    export TF_VAR_admin_password="Passw0rd!"

### Exercice 4

Créer deux environnements :

    terraform apply -var-file=dev.tfvars
    terraform apply -var-file=prod.tfvars
