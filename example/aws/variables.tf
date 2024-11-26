variable "nom-instance" {
    type=string
    description="Nom de l'instance"
}

variable "secret" {
    type=string
    description="mon super secret"
    sensitive = true
}

variable "SSH_PUB_KEY" {
    type = string
    sensitive = true
}