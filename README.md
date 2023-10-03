# three-tier-eks-iac

#Install/update latest AWS CLI:
https://aws.amazon.com/cli/

#update the Kubernetes context
aws eks update-kubeconfig --name my-eks-cluster --region us-west-2

#verify access:

kubectl auth can-i "*" "*"


kubectl get nodes


#Verify autoscaler running:
kubectl get pods -n kube-system

#Check Autoscaler logs
kubectl logs -f \
  -n kube-system \
  -l app=cluster-autoscaler

#Check load balancer logs
kubectl logs -f -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller


#deploy Sample Apps
kubectl apply -f k8s_manifests/nginx.yaml

kubectl apply -f k8s_manifests/echoserver.yaml

kubectl delete -f k8s_manifests/nginx.yaml

kubectl delete -f k8s_manifests/echoserver.yaml


aws eks update-kubeconfig \
  --name my-eks \
  --region us-west-2 \
  --profile eks-admin


kubectl logs -f -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller


Buid Docker image :
For Mac:
export DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx create --name mybuilder --use
docker buildx inspect mybuilder --bootstrap
docker buildx build --platform linux/amd64 -t your-image-name:tag . 
docker buildx rm mybuilder


