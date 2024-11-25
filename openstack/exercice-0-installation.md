# Installation de l'environnement

## Objectifs

- Avoir un environnement Openstack fonctionnel
- Avoir Terraform installé et fonctionnel

## Pré-requis

- Avoir virtualBox installé sur la machine à utiliser
- Télécharger l'image qui se trouve ici :
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
  

- 
