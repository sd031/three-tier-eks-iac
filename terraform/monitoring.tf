# resource "time_sleep" "wait_for_kubernetes" {

#     depends_on = [
#        module.eks
#     ]

#     create_duration = "20s"
# }

# resource "kubernetes_namespace" "kube-namespace" {
#   depends_on = [time_sleep.wait_for_kubernetes]
#   metadata {
    
#     name = "prometheus"
#   }
# }

# resource "helm_release" "prometheus" {
#   depends_on = [kubernetes_namespace.kube-namespace, time_sleep.wait_for_kubernetes]
#   name       = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   namespace  = kubernetes_namespace.kube-namespace.id
#   create_namespace = true
#   version    = "51.3.0"
#   values = [
#     file("values.yaml")
#   ]
#   timeout = 2000
  

# set {
#     name  = "podSecurityPolicy.enabled"
#     value = true
#   }

#   set {
#     name  = "server.persistentVolume.enabled"
#     value = false
#   }

#   # You can provide a map of value using yamlencode. Don't forget to escape the last element after point in the name
#   set {
#     name = "server\\.resources"
#     value = yamlencode({
#       limits = {
#         cpu    = "200m"
#         memory = "50Mi"
#       }
#       requests = {
#         cpu    = "100m"
#         memory = "30Mi"
#       }
#     })
#   }
# }