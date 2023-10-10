# Launch minikube tunnel in backgroud
minikube tunnel &> /dev/null &

# Create only namespace
terraform apply -target=kubernetes_namespace.vanessakovalsky 
# equivalent à : kubect create namespace toto

# Create configmap
kubectl create configmap myconfig --from-literal=lang=fr -n toto

# Launch terraform apply
terraform apply 