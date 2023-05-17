variable "AWS_ACCESS_KEY" {
    type = string
}

variable "AWS_SECRET_KEY" {
    type = string
}

variable "AWS_REGION" {
  type = string
  default = "us-east-1"
}

variable "AWS_AMI" {
    type = string
}

variable "SSH_PUB_KEY" {
  type = string
}