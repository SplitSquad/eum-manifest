terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Local Values
locals {
  cluster_name = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Team        = "platform"
  }

  availability_zones = data.aws_availability_zones.available.names

  # 🆕 조건부 애드온 설정
  cluster_addons = merge(
    # 기본 필수 애드온들
    {
      coredns = {
        addon_version            = var.coredns_version
        resolve_conflicts        = "OVERWRITE"
        service_account_role_arn = null
      }
      kube-proxy = {
        addon_version            = var.kube_proxy_version
        resolve_conflicts        = "OVERWRITE"
        service_account_role_arn = null
      }
      vpc-cni = {
        addon_version            = var.vpc_cni_version
        resolve_conflicts        = "OVERWRITE"
        service_account_role_arn = null
      }
      aws-ebs-csi-driver = {
        addon_version            = var.ebs_csi_version
        resolve_conflicts        = "OVERWRITE"
        service_account_role_arn = module.iam.ebs_csi_role_arn
      }
    },
    # 선택적 애드온들
    var.enable_pod_identity ? {
      eks-pod-identity-agent = {
        addon_version            = var.pod_identity_version
        resolve_conflicts        = "OVERWRITE"
        service_account_role_arn = null
      }
    } : {},
    var.enable_node_monitoring ? {
      amazon-cloudwatch-observability = {
        addon_version            = var.node_monitoring_version
        resolve_conflicts        = "OVERWRITE"
        service_account_role_arn = null
      }
    } : {},
    var.enable_external_dns ? {
      external-dns = {
        addon_version            = var.external_dns_version
        resolve_conflicts        = "OVERWRITE"
        service_account_role_arn = null
      }
    } : {},
    var.enable_metrics_server ? {
      metrics-server = {
        addon_version            = var.metrics_server_version
        resolve_conflicts        = "OVERWRITE"
        service_account_role_arn = null
      }
    } : {}
  )
}

# Data Sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  cluster_name            = local.cluster_name
  vpc_cidr                = var.vpc_cidr
  availability_zones      = local.availability_zones
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  common_tags             = local.common_tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  cluster_name      = local.cluster_name
  oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  oidc_provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  common_tags       = local.common_tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  cluster_name              = local.cluster_name
  kubernetes_version        = var.kubernetes_version
  cluster_role_arn          = module.iam.cluster_role_arn
  node_group_role_arn       = module.iam.node_group_role_arn
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr_block            = module.vpc.vpc_cidr_block
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  endpoint_private_access   = var.endpoint_private_access
  endpoint_public_access    = var.endpoint_public_access
  public_access_cidrs       = var.public_access_cidrs
  enabled_cluster_log_types = var.enabled_cluster_log_types
  log_retention_days        = 7  # 기본값으로 설정 (로깅이 활성화된 경우)
  
  node_groups = var.node_groups
  
  # 🔧 실제 환경과 일치하는 애드온 설정
  cluster_addons = local.cluster_addons

  common_tags = local.common_tags

  depends_on = [module.vpc, module.iam]
} 