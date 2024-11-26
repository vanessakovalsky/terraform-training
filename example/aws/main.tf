terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws"  {

    region = "eu-west-3"
}

variable "nom-instance" {
    type=string
    description="Nom de l'instance"
}

variable "secret" {
    type=string
    description="mon super secret"
    sensitive = true
}

resource "aws_s3_bucket" "example" {
    bucket = var.nom-instance
    tags = {
        Name        = "My bucket"
        Environment = "Dev"
        Secret = var.secret
    }
}

output "arn_bucket_demo"{
    description = "Valeur de l'ARN du bucket créé par terraform"
    value= aws_s3_bucket.example.arn 
}