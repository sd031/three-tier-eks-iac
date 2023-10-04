# three-tier-eks-iac

#Install/update latest AWS CLI:
https://aws.amazon.com/cli/

#update the Kubernetes context
aws eks update-kubeconfig --name my-eks-cluster --region us-west-2

eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster my-eks-cluster \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve

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
docker buildx build --platform linux/amd64 -t backend:v1 . 
docker buildx rm mybuilder

docker buildx build --platform linux/amd64 -t workshop-frontend:v1 . 

docker tag workshop-frontend:v1 public.ecr.aws/w8u5e4v2/workshop-frontend:v1

docker push public.ecr.aws/w8u5e4v2/workshop-frontend:v1


docker buildx build --platform linux/amd64 -t workshop-backend:v1 . 

docker buildx build --platform linux/amd64 -t workshop-backend:v1 . 
docker tag workshop-backend:v1 public.ecr.aws/w8u5e4v2/workshop-backend:v1
docker push public.ecr.aws/w8u5e4v2/workshop-backend:v1

kubectl exec -it api-57f87d89bf-4dwbj -ns workshop -- /bin/sh

docker build -t workshop-backend .



#Create Namespace
```
kubectl create ns workshop

kubectl config set-context --current --namespace workshop
```
**MONGO Database Setup**



To create Mongo statefulset with Persistent volumes, run the command in manifests folder:
```
kubectl delete -f mongo-statefulset.yaml
kubectl apply -f mongo-statefulset.yaml
```

Mongo Service
```
kubectl apply -f mongo-service.yaml
```

Create a temporary network utils pod. Enter into a bash session within it. In the terminal run the following command:
```
kubectl run --rm utils -it --image praqma/network-multitool -- bash
```
Within the new utils pod shell, execute the following DNS queries:
```
for i in {0..2}; do nslookup mongo-$i.mongo; done
```
Note: This confirms that the DNS records have been created successfully and can be resolved within the cluster, 1 per MongoDB pod that exists behind the Headless Service - earlier created. 

Exit the utils container
```
exit
```

On the `mongo-0` pod, initialise the Mongo database Replica set. In the terminal run the following command:
```
cat << EOF | kubectl exec -it mongo-0 -- mongo
rs.initiate();
sleep(2000);
rs.add("mongo-1.mongo:27017");
sleep(2000);
rs.add("mongo-2.mongo:27017");
sleep(2000);
cfg = rs.conf();
cfg.members[0].host = "mongo-0.mongo:27017";
rs.reconfig(cfg, {force: true});
sleep(5000);
EOF
```

Note: Wait until this command completes successfully, it typically takes 10-15 seconds to finish, and completes with the message: bye


To confirm run this in the terminal:
```
kubectl exec -it mongo-0 -- mongo --eval "rs.status()" | grep "PRIMARY\|SECONDARY"
```

Load the Data in the database by running this command:
## Note: use langdb not langdb() as shown in the video
```
cat << EOF | kubectl exec -it mongo-0 -- mongo
use langdb;
db.languages.insert({"name" : "csharp", "codedetail" : { "usecase" : "system, web, server-side", "rank" : 5, "compiled" : false, "homepage" : "https://dotnet.microsoft.com/learn/csharp", "download" : "https://dotnet.microsoft.com/download/", "votes" : 0}});
db.languages.insert({"name" : "python", "codedetail" : { "usecase" : "system, web, server-side", "rank" : 3, "script" : false, "homepage" : "https://www.python.org/", "download" : "https://www.python.org/downloads/", "votes" : 0}});
db.languages.insert({"name" : "javascript", "codedetail" : { "usecase" : "web, client-side", "rank" : 7, "script" : false, "homepage" : "https://en.wikipedia.org/wiki/JavaScript", "download" : "n/a", "votes" : 0}});
db.languages.insert({"name" : "go", "codedetail" : { "usecase" : "system, web, server-side", "rank" : 12, "compiled" : true, "homepage" : "https://golang.org", "download" : "https://golang.org/dl/", "votes" : 0}});
db.languages.insert({"name" : "java", "codedetail" : { "usecase" : "system, web, server-side", "rank" : 1, "compiled" : true, "homepage" : "https://www.java.com/en/", "download" : "https://www.java.com/en/download/", "votes" : 0}});
db.languages.insert({"name" : "nodejs", "codedetail" : { "usecase" : "system, web, server-side", "rank" : 20, "script" : false, "homepage" : "https://nodejs.org/en/", "download" : "https://nodejs.org/en/download/", "votes" : 0}});

db.languages.find().pretty();
EOF
```

Create Mongo secret:
```
kubectl apply -f mongo-secret.yaml
```

**API Setup**

Create GO API deployment by running the following command:
```
kubectl apply -f api-deployment.yaml
```

Expose API deployment through service using the following command:
```
kubectl expose deploy api \
 --name=api \
 --type=LoadBalancer \
 --port=80 \
 --target-port=8080
```

Next set the environment variable:

```
{
API_ELB_PUBLIC_FQDN=$(kubectl get svc api -ojsonpath="{.status.loadBalancer.ingress[0].hostname}")
until nslookup $API_ELB_PUBLIC_FQDN >/dev/null 2>&1; do sleep 2 && echo waiting for DNS to propagate...; done
curl $API_ELB_PUBLIC_FQDN/ok
echo
}
```

Test and confirm that the API route URL /languages, and /languages/{name} endpoints can be called successfully. In the terminal run any of the following commands:
```
curl -s $API_ELB_PUBLIC_FQDN/languages | jq .
curl -s $API_ELB_PUBLIC_FQDN/languages/go | jq .
curl -s $API_ELB_PUBLIC_FQDN/languages/java | jq .
curl -s $API_ELB_PUBLIC_FQDN/languages/nodejs | jq .
```

If everything works fine, go ahead with Frontend setup.
```
{
API_ELB_PUBLIC_FQDN=$(kubectl get svc api -ojsonpath="{.status.loadBalancer.ingress[0].hostname}")
echo API_ELB_PUBLIC_FQDN=$API_ELB_PUBLIC_FQDN
}
```

**Frontend setup**

Create the Frontend Deployment resource. In the terminal run the following command:
```
kubectl apply -f frontend-deployment.yaml
```

Create a new Service resource of LoadBalancer type. In the terminal run the following command:
```
kubectl expose deploy frontend \
 --name=frontend \
 --type=LoadBalancer \
 --port=80 \
 --target-port=8080
```

Confirm that the Frontend ELB is ready to recieve HTTP traffic. In the terminal run the following command:
```
{
FRONTEND_ELB_PUBLIC_FQDN=$(kubectl get svc frontend -ojsonpath="{.status.loadBalancer.ingress[0].hostname}")
until nslookup $FRONTEND_ELB_PUBLIC_FQDN >/dev/null 2>&1; do sleep 2 && echo waiting for DNS to propagate...; done
curl -I $FRONTEND_ELB_PUBLIC_FQDN
}
```

Generate the Frontend URL for browsing. In the terminal run the following command:
```
echo http://$FRONTEND_ELB_PUBLIC_FQDN
```

Test the full end-to-end cloud native application

 Using your local workstation's browser - browse to the URL created in the previous output.




Query the MongoDB database directly to observe the updated vote data. In the terminal execute the following command:
```
kubectl exec -it mongo-0 -- mongo langdb --eval "db.languages.find().pretty()"