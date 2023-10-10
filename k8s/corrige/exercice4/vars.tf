# name : nom du déploiement

variable "name" {
    type = string
    description = "nom du déploiement"
}

# app_name : nom de l'application

variable "app_name" {
    type = string
    description = "nom de l'application"
}

# namespace : nom du namespace à créer et à utiliser

variable "namespace" {
    type = string
    description = "nom du namespace à créer et à utiliser"
}

# image : identifiant et version de l'image à utiliser

variable "image" {
    type = string
    description = "identifiant et version de l'image à utiliser"
}

# port : port à exposer dans le service

variable "port" {
    type = number
    description = "port à exposer dans le service"
}

variable "env" {
    type = string
    default = "prod"
}