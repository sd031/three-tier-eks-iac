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


aws eks update-kubeconfig \
  --name my-eks \
  --region us-west-2 \
  --profile eks-admin


kubectl logs -f -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller


Min LB Permission:

{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
         "elasticloadbalancing:CreateTargetGroup"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
         "elasticloadbalancing:AddTags"
      ],
      "Resource": "*",
      "Condition": {
         "StringEquals": {
             "elasticloadbalancing:CreateAction" : "CreateTargetGroup"
          }
       }
    }
  ]
}