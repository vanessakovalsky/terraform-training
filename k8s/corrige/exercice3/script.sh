# Launch minikube tunnel in backgroud
minikube tunnel &> /dev/null &

# Create only namespace
terraform apply -target=kubernetes_namespace.vanessakovalsky -var-file=k8s.tfvars

# Create configmap
kubectl create configmap myconfig --from-literal=lang=fr -n toto

# Launch terraform apply
terraform apply -var-file=k8s.tfvars