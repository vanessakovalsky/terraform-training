# Exercice 4  conditions et boucles

## Objectifs

Cet exercice a pour objectifs :
* d'ajouter des conditions à nos deploiements
* de définir des boucles pour créer plusieurs ressources

## Conditions 

* Nous allons rendre certains élements conditionnels, c'est à dire que certaines informations seront spécifique à certains paramètres, ou que certaines ressources ne seront créés que lorsque les conditions sont remplies
* Pour cela : ajouter une variable env avec une valeur par defaut à dev
* Dans le code de création de nos ressource, mettre le type de service à ClusterIp si on est en environnement de dev, et à LoadBalancer si la valeur de `env` vaut `prod`
* Créer une ressource de type secret avec un secret encodé en base 64, en utilisant les fonctions de terraform. 
* Si l'environnement est différent de la valeur `dev` : ajouter à Nginx une autentification HTTP Basic Auth utilise le secret crée. 
    * Pour cela vous devez créer un fichier `.htpasswd`, utiliser par exemple ce générateur : https://hostingcanada.org/htpasswd-generator/ 
    * Ensuite vous devez créer un secret qui utilise la fonction file pour charger votre fichier 
    * Ensuite dans le deploiement au niveau de la spec du pod ajouter les annotations suivantes :
    ```
    annotations:
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: htpasswd
    nginx.ingress.kubernetes.io/auth-realm: "Enter your credentials"
    ```
    * Vous pouvez maintenant redeployer et tenter d'accèder à votre nginx qui devrait vous demander le un identifiant et un mot de passe

## Boucles

* Ajouter une variable user de type liste  qui contient une liste d'utilisateur 
* Ajouter une variable de type password qui contient une liste de mot de passe
* Dans le config map de secret, ajouter une boucle qui pour chaque utilisateur va ajouter une donnée sous la forme : user:base64encode(password) 
* Puis redeployer et essayer de vous connecter avec les différents utilisateurs de votre liste sur votre site nginx
