variable "argocd_namespace" {
  description = "ArgoCD가 설치될 네임스페이스"
  type        = string
  default     = "argocd"
}

variable "git_repo_url" {
  description = "Git 저장소 URL"
  type        = string
  default     = "https://github.com/SplitSquad/eum-manifest.git"
}

variable "git_target_revision" {
  description = "Git 브랜치"
  type        = string
  default     = "main"
}

variable "applications" {
  description = "ArgoCD 애플리케이션 설정"
  type = map(object({
    name           = string
    namespace      = string
    path           = string
    values_files   = list(string)
    create_namespace = bool
  }))
  default = {
    "eum-ai" = {
      name           = "eum-ai"
      namespace      = "eum-ai"
      path           = "helm-charts/eum-ai"
      values_files   = ["values.yaml"]
      create_namespace = true
    }
    "eum-backend" = {
      name           = "eum-backend"
      namespace      = "eum-backend"
      path           = "helm-charts/eum-backend"
      values_files   = ["values.yaml"]
      create_namespace = true
    }
    "eum-infra" = {
      name           = "eum-infra"
      namespace      = "eum-infra"
      path           = "helm-charts/eum-infra"
      values_files   = ["values.yaml"]
      create_namespace = true
    }
  }
} 