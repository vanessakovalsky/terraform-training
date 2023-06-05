terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.17.0"
    }
  }
}

module "k8s_wordpress" {
    source = "./modules/k8s-wordpress"
    app_name = "devopssec-terraform"
    namespace = "mynamespace"
}