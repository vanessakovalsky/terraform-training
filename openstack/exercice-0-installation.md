# Installation de l'environnement

## Objectifs

- Avoir un environnement Openstack fonctionnel
- Avoir Terraform installé et fonctionnel

## Pré-requis

- Avoir virtualBox installé sur la machine à utiliser
- Télécharger l'image qui se trouve ici : https://www.grosfichiers.com/HuquECmjYpC
- Avoir une machine avec au moins 16GO de RAM et 8 CPU (la VM va en utiliser la moitié) et 20 GO de disque dur disponible

## Lancement de la VM OpenStack

- Ouvrir VirtualBox
- Cliquer sur `FIchier > Importer un appareil Virtuel`
- Sélectionner le fichier télécharger dans les prérequis et suivre les étapes d'import.
- Une fois la machine importé, vous devriez avoir une machine nommé Devstack2 (si vous ne l'avez pas renommé)
- Lancer la machine (mot de passe : changeme --> /!\ le clavier est en qwerty)
- Dans la VM, ouvrir un terminal et taper les commandes suivantes :
```shell
su -
su - stack
export HOST_IP=127.0.0.1
cd devstack
source openrc
```
- Une fois ces commandes passé et toujours dans la VM, ouvrir un navigateur et tapez : http://127.0.0.1/dashboard -> vous devez arrivé sur la page de connexion d'Openstack
  
## Installation de Terraform

* -> installer terraform dans la VM avec openstack

* En fonction de votre système d'exploitation, suivre les informations d'installations officielles ici : 
https://www.terraform.io/downloads 
* Pour tester votre installation, ouvrez un terminal ou une invite de commande et taper la commande 
```
terraform -help
```
* Vous devriez obtenir une réponse comme celle-ci :
```
Usage: terraform [global options] <subcommand> [args]

The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.

Main commands:
  init          Prepare your working directory for other commands
  validate      Check whether the configuration is valid
  plan          Show changes required by the current configuration
  apply         Create or update infrastructure
  destroy       Destroy previously-created infrastructure

All other commands:
  console       Try Terraform expressions at an interactive command prompt
  fmt           Reformat your configuration in the standard style
  force-unlock  Release a stuck lock on the current workspace
  get           Install or upgrade remote Terraform modules
  graph         Generate a Graphviz graph of the steps in an operation
  import        Associate existing infrastructure with a Terraform resource
  login         Obtain and save credentials for a remote host
  logout        Remove locally-stored credentials for a remote host
  output        Show output values from your root module
  providers     Show the providers required for this configuration
  refresh       Update the state to match remote systems
  show          Show the current state or a saved plan
  state         Advanced state management
  taint         Mark a resource instance as not fully functional
  test          Experimental support for module integration testing
  untaint       Remove the 'tainted' state from a resource instance
  version       Show the current Terraform version
  workspace     Workspace management

Global options (use these before the subcommand, if any):
  -chdir=DIR    Switch to a different working directory before executing the
                given subcommand.
  -help         Show this help output, or the help for a specified subcommand.
  -version      An alias for the "version" subcommand.
```
