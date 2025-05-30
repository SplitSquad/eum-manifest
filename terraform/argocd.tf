# ArgoCD Namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# ArgoCD Installation via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.46.8"  # 원하는 버전으로 변경

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"  # 또는 LoadBalancer/NodePort
        }
        ingress = {
          enabled = false  # 필요시 true로 변경
        }
      }
      configs = {
        params = {
          "server.insecure" = true  # HTTPS 없이 사용시
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# ArgoCD CLI 설정을 위한 포트포워딩 (선택사항)
# kubectl port-forward svc/argocd-server -n argocd 8080:443 