resource "kubernetes_namespace" "appwordpress" {
    metadata {
        name = "${var.namespace}"
    }
}

resource "kubernetes_secret" "example" {
  metadata {
    name = "mysql-pass"
    namespace = var.namespace
  }

  data = {
    password = "P4ssw0rd"
  }

  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_manifest" "service_wordpress" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app" = "wordpress"
      }
      "name" = "wordpress"
      "namespace" = var.namespace
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
        },
      ]
      "selector" = {
        "app" = "wordpress"
        "tier" = "frontend"
      }
      "type" = "NodePort"
    }
  }
}

resource "kubernetes_manifest" "persistentvolumeclaim_wp_pv_claim" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolumeClaim"
    "metadata" = {
      "labels" = {
        "app" = "wordpress"
      }
      "name" = "wp-pv-claim"
      "namespace" = var.namespace
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "resources" = {
        "requests" = {
          "storage" = "20Gi"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_wordpress" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "wordpress"
      }
      "name" = "wordpress"
      "namespace" = var.namespace
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "wordpress"
          "tier" = "frontend"
        }
      }
      "strategy" = {
        "type" = "Recreate"
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "wordpress"
            "tier" = "frontend"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "WORDPRESS_DB_HOST"
                  "value" = "wordpress-mysql"
                },
                {
                  "name" = "WORDPRESS_DB_PASSWORD"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "password"
                      "name" = "mysql-pass"
                    }
                  }
                },
              ]
              "image" = "wordpress:4.8-apache"
              "name" = "wordpress"
              "ports" = [
                {
                  "containerPort" = 80
                  "name" = "wordpress"
                },
              ]
              "volumeMounts" = [
                {
                  "mountPath" = "/var/www/html"
                  "name" = "wordpress-persistent-storage"
                },
              ]
            },
          ]
          "volumes" = [
            {
              "name" = "wordpress-persistent-storage"
              "persistentVolumeClaim" = {
                "claimName" = "wp-pv-claim"
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_wordpress_mysql" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app" = "wordpress"
      }
      "name" = "wordpress-mysql"
      "namespace" = var.namespace
    }
    "spec" = {
      "clusterIP" = "None"
      "ports" = [
        {
          "port" = 3306
        },
      ]
      "selector" = {
        "app" = "wordpress"
        "tier" = "mysql"
      }
    }
  }
}

resource "kubernetes_manifest" "persistentvolumeclaim_mysql_pv_claim" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolumeClaim"
    "metadata" = {
      "labels" = {
        "app" = "wordpress"
      }
      "name" = "mysql-pv-claim"
      "namespace" = var.namespace
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "resources" = {
        "requests" = {
          "storage" = "20Gi"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_wordpress_mysql" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "wordpress"
      }
      "name" = "wordpress-mysql"
      "namespace" = var.namespace
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "wordpress"
          "tier" = "mysql"
        }
      }
      "strategy" = {
        "type" = "Recreate"
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "wordpress"
            "tier" = "mysql"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "MYSQL_ROOT_PASSWORD"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "password"
                      "name" = "mysql-pass"
                    }
                  }
                },
              ]
              "image" = "mysql:5.6"
              "name" = "mysql"
              "ports" = [
                {
                  "containerPort" = 3306
                  "name" = "mysql"
                },
              ]
              "volumeMounts" = [
                {
                  "mountPath" = "/var/lib/mysql"
                  "name" = "mysql-persistent-storage"
                },
              ]
            },
          ]
          "volumes" = [
            {
              "name" = "mysql-persistent-storage"
              "persistentVolumeClaim" = {
                "claimName" = "mysql-pv-claim"
              }
            },
          ]
        }
      }
    }
  }
}