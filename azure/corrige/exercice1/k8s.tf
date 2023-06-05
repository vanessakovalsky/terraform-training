terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.17.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_namespace" "vanessakovalsky" {
    metadata {
        name = "vanessakovalsky"
    }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "terraform-example"
    labels = {
      app = "MyExampleApp"
    }
    namespace = "vanessakovalsky"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "MyExampleApp"
      }
    }

    template {
      metadata {
        labels = {
          app = "MyExampleApp"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "example"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginxsvc" {
  metadata {
    name = "terraform-example-svc"
    namespace = "vanessakovalsky"
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}