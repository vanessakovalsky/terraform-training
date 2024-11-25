# Exercice 5 - Déployer automatiquement avec Terraform depuis une chaine de CI/CD

## Objectifs

Cet exercice a pour objectifs : 
* de tester le code produits pour terraform dans une chaine de CI
* de déployer automatiquement l'infrastructure via une chaine de CD

Nous allons déployer une chaine de CI/CD avec gitlab avec les étapes suivantes :
![](https://blog.filador.fr/content/images/2023/03/terraform-cicd.png)

## Pré-requis

* Avoir un depôt Gitlab configurer avec le code terraform dedans
* Avoir une chaine de CI configurée sur gitlab-ci (avec un runner fonctionnel)

## Intégration continue

### Présentation des outils

* terraformt fmt est inclus dans terraform et fait une vérification syntaxique basique du code, pour vérifier notamment son indentation. 
* tflint : est un Linter qui détecte les erreurs de syntaxes en fonction des règles définies dans un fichier tflint.hcl (il est possible de définir ses propres règles)
* checkov est un outil de Policy-as-code qui permet d'identifier els erreurs de configurations sur des outils d'IAC
* terratest est une bibliothèque en Go qui permet de créer des tests d'infrastructure pour terraform

### Mis en place de la chaine de vérification

* Notre pipeline de CI contiendra 4 étapes utilisant chacun des outils présentés.
* Commençons avec la validation de terraform fmt :
```
format:
  stage: check
  image:
    name: hashicorp/terraform:${TERRAFORM_IMAGE_VERSION}
    entrypoint:
      - "/usr/bin/env"
      - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  script:
    - terraform fmt -check -recursive -write=false -diff
```
* Ici nous utilisons l'image officielle de terraform pour utiliser la commande fmt
* Ajoutons ensuite tflint
```
tflint:
  stage: check
  image:
    name: ghcr.io/terraform-linters/tflint:${TFLINT_IMAGE_VERSION}
    entrypoint:
      - "/usr/bin/env"
      - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  script:
    # Get all folders with tf files inside and do tflint command
    - |
      find . -name '*.tf' -not -path '*.terraform*' | rev | cut -d'/' -f2- | rev \
      | uniq \
      | xargs -I {} sh -c "echo {}: && tflint -c tflint.hcl {}"
```
* La encore nous utilisons l'image officielle de tflint puis nous executons la commande sur l'ensemble des dossiers contentant des fichiers au format tf utilisé par terraform
* Ajoutons maintenant checkov :
```
checkov:
  stage: check
  image:
    name: bridgecrew/checkov:${CHECKOV_IMAGE_VERSION}
    entrypoint:
      - "/usr/bin/env"
      - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  script:
    # Get all folders with tf files inside and do checkov command
    - |
      find . -name '*.tf' -not -path '*.terraform*' | rev | cut -d'/' -f2- | rev \
      | uniq \
      | xargs -I {} sh -c "echo {}: && checkov -d {}"
```
* Comme précédemment, nous utilisons l'image officiel et utilisons le binaire sur l'ensemble des fichiers terraform

###(optionnel) Mise en place des tests avec terratest

* Nous avons besoin d'écrire des tests en go, pour cela voir la [documentation de terratest](https://terratest.gruntwork.io/docs/getting-started/quick-start/)
* Une fois les tests écrits, nous pouvons ajouter l'étape dans notre pipeline :
```
terratest:
  stage: test
  image:
    name: hashicorp/terraform:${TERRAFORM_IMAGE_VERSION}
    entrypoint:
      - "/usr/bin/env"
      - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  before_script:
    # Install Go
    - apk add --no-cache go=1.19.7-r0
    # Init Google Cloud service account
    - echo ${GOOGLE_CLOUD_SERVICE_ACCOUNT} > ${CI_PROJECT_DIR}/google-cloud-service-account.json
    - export GOOGLE_APPLICATION_CREDENTIALS=${CI_PROJECT_DIR}/google-cloud-service-account.json
  script:
    - cd test
    - go mod init filador.fr/google-cloud-free-tier
    - go mod tidy -compat=1.19
    - go test -v -run TestTerraformEndToEnd -timeout 30m
  after_script:
    - unset GOOGLE_APPLICATION_CREDENTIALS
    - shred -u ${CI_PROJECT_DIR}/google-cloud-service-account.json
```
* Dans cet exemple nous utilisons une clé de connexion pour GCP qui est définit dans les variables de Gitlab CI 
* Nous partons alors de l'image de terraform et ajoutons les éléments manquants pour l'execution de terratest
* Une fois executée vous saurez alors si les tests sont passés ou non

## Déploiement avec Gitlab CI

* Ensuite nous ajoutons à notre pipeline les étapes de déploiement : validate, build, deploy
* Pour cela vous pouvez utiliser directement le template fournit par Gitlab CI : https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Terraform/Base.gitlab-ci.yml à l'aide de la [documentation associée](https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_template_recipes.html)