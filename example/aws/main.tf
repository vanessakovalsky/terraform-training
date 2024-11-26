terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "my-s3-bucket-bis"
    region = "eu-west-3"
    key= "./terraform.tfstate"
  }
}

provider "aws"  {
    region = "eu-west-3"
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket-bis"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

module "monsupermodule" {
  # l'endroit dans lequel se trouve mon module (local ou distant)
  source = "./monmodule"

  # les valeurs des variables que le module attends 
  KEY_NAME = "masupercledemonmodule"
  SSH_PUB_KEY = var.SSH_PUB_KEY
}