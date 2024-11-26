variable "KEY_NAME" {
  type= string
}

variable "SSH_PUB_KEY" {
    type = string
    sensitive = true
}