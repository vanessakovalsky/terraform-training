# Exercise 5 - Deploy automatically with Terraform from a CI/CD chain

## Goals
This exercise aims to:
* to test the product code for terraform in a CI chain
* automatically deploy the infrastructure via a chain of CDs
We will deploy a CI/CD chain with gitlab with the following steps:
![](https://blog.filador.fr/content/images/2023/03/terraform-cicd.png)

## Prerequisites
* Have a Gitlab repository configured with the terraform code in it
* Have a CI chain configured on gitlab-ci (with a working runner)

## Continuous integration

### Presentation of the tools
* terraformt fmt is included in terraform and does a basic syntax check of the code, in particular to check its indentation.
* tflint: is a Linter that detects syntax errors according to the rules defined in a tflint.hcl file (it is possible to define your own rules)
* checkov is a Policy-as-code tool that identifies configuration errors on IAC tools* terratest is a Go library for creating infrastructure tests for terraform

### Implementation of the verification chain
* Our CI pipeline will contain 4 stages using each of the featured tools.
* Let's start with terraform fmt validation:
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
* Here we use the official terraform image to use the fmt command
* Then add tflint stage
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
| unic \      | xargs -I {} sh -c "echo {}: && tflint -c tflint.hcl {}"
```
* Here again we use the official image of tflint then we execute the command on all the folders containing files in the tf format used by terraform
* Now let's add checkov stage:
```
checks:  stage: check
  image:
    name: bridgecrew/checkov:${CHECKOV_IMAGE_VERSION}
    entrypoint:
      - "/usr/bin/env"
      - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  script:
    # Get all folders with tf files inside and do checkov command
    - |
      find . -name '*.tf' -not -path '*.terraform*' | rev | cut -d'/' -f2- | rev \
| unic \      | xargs -I {} sh -c "echo {}: && checkov -d {}"
```
* As before, we use the official image and use the binary on all terraform files
###(optional) Setting up tests with terratest
* We need to write tests in go, for that see the [terratest documentation](https://terratest.gruntwork.io/docs/getting-started/quick-start/)
* Once the tests are written, we can add the stage in our pipeline:
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
* In this example we use a connection key for GCP which is defined in the variables of Gitlab CI
* We then start from the terraform image and add the missing elements for the execution of terratest
* Once executed you will then know if the tests are passed or not

## Deployment with Gitlab CI

* Then we add to our pipeline the deployment steps: validate, build, deploy
* For this you can directly use the template provided by Gitlab CI: https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Terraform/Base.gitlab-ci. yml using [related documentation](https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_template_recipes.html)