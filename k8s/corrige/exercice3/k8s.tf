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
        name = "${var.namespace}"
    }
}

data "kubernetes_config_map" "exemple" {
  metadata {
    name = "myconfig"
    namespace = "${var.namespace}"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "${var.name}"
    labels = {
      app = "${var.app_name}"
    }
    namespace = "${var.namespace}"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "${var.app_name}"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.app_name}"
        }
      }

      spec {
        container {
          image = "${var.image}"
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
          env_from {
            config_map_ref {
              name = data.kubernetes_config_map.exemple.metadata.0.name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginxsvc" {
  metadata {
    name = "${var.name}-svc"
    namespace = "${var.namespace}"
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = "${var.port}"
    }

    type = "LoadBalancer"
  }
}

# Affiche une données depuis une ressource créé par terraform
output "terraform_example_node_port_ip" {
  value = "${kubernetes_service.nginxsvc.spec.0.cluster_ip}"
}