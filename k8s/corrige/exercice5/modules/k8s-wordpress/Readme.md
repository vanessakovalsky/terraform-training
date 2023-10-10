# K8S - Wordpress

Ce module provisionne les ressources nécessaires au déploiement d'un site Wordpress dans un cluster Kubernetes.

## Usage

```hcl
module "<module name>" {
    source = "path of your module"
    site_name = "<UNIQ SITE NAME>"
    tags = {
        key   = "<value>"
    }
}
```