# Exercise 4 conditions and loops

## Goals

This exercise aims to:
* add conditions to our deployments
* define loops to create multiple resources

## Conditions

* We will make some items conditional, i.e. some information will be specific to some parameters, or some resources will only be created when the conditions are met
* For this: add an env variable with a default value to dev
* In the code for creating our resources, set the type of service to ClusterIp if we are in a dev environment, and to LoadBalancer if the value of `env` is `prod`
* Create a secret type resource with a base 64 encoded secret, using terraform functions.
* If the environment is different from the `dev` value: add an HTTP Basic Auth to Nginx using the created secret.
    * For this you must create a `.htpasswd` file, use for example this generator: https://hostingcanada.org/htpasswd-generator/
    * Next you need to create a secret that uses the file function to load your file
    * Then in the deployment at the pod spec level add the following annotations:
    ```
    annotations:
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: htpasswd
    nginx.ingress.kubernetes.io/auth-realm: "Enter your credentials"
    ```
    * You can now redeploy and attempt to access your nginx which should prompt you for a username and password

## Loop

* Add a user variable of type list which contains a list of users
* Add a variable of type password which contains a list of passwords
* In the secret config map, add a loop which for each user will add data in the form: user:base64encode(password)
* Then redeploy and try to connect with the different users in your list on your nginx site

