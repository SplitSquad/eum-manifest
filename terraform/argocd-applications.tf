# EUM AI Application
resource "kubectl_manifest" "eum_ai_application" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "eum-ai"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/SplitSquad/eum-manifest.git"
        targetRevision = "main"
        path           = "helm-charts/eum-ai"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "eum-ai"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  })
}

# EUM Backend Application
resource "kubectl_manifest" "eum_backend_application" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "eum-backend"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/SplitSquad/eum-manifest.git"
        targetRevision = "main"
        path           = "helm-charts/eum-backend"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "eum-backend"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  })
}

# EUM Infra Application
resource "kubectl_manifest" "eum_infra_application" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "eum-infra"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/SplitSquad/eum-manifest.git"
        targetRevision = "main"
        path           = "helm-charts/eum-infra"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "eum-infra"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  })
} 