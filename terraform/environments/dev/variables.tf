# General Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "eum"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
}

# EKS Variables
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "List of control plane logging to enable"
  type        = list(string)
  default     = []
}

# Node Groups
variable "node_groups" {
  description = "Map of EKS node group configurations"
  type = map(object({
    capacity_type               = string
    instance_types              = list(string)
    ami_type                    = string
    disk_size                   = number
    desired_size                = number
    max_size                    = number
    min_size                    = number
    max_unavailable_number      = number
    ec2_ssh_key                 = string
    tags                        = map(string)
  }))
  default = {
    main = {
      capacity_type               = "ON_DEMAND"
      instance_types              = ["t3.2xlarge"]
      ami_type                    = "AL2_x86_64"
      disk_size                   = 40
      desired_size                = 2
      max_size                    = 3
      min_size                    = 1
      max_unavailable_number      = 1
      ec2_ssh_key                 = ""
      tags = {
        WorkloadType = "general"
      }
    }
  }
}

# EKS Add-on Versions
variable "coredns_version" {
  description = "CoreDNS add-on version"
  type        = string
  default     = "v1.11.4-eksbuild.2"
}

variable "kube_proxy_version" {
  description = "kube-proxy add-on version"
  type        = string
  default     = "v1.32.0-eksbuild.2"
}

variable "vpc_cni_version" {
  description = "VPC CNI add-on version"
  type        = string
  default     = "v1.19.2-eksbuild.1"
}

variable "ebs_csi_version" {
  description = "EBS CSI driver add-on version"
  type        = string
  default     = "v1.43.0-eksbuild.1"
}

# EKS Add-ons
variable "enable_pod_identity" {
  description = "Enable EKS Pod Identity agent"
  type        = bool
  default     = true
}

variable "pod_identity_version" {
  description = "EKS Pod Identity agent version"
  type        = string
  default     = "v1.3.4-eksbuild.1"
}

variable "enable_node_monitoring" {
  description = "Enable node monitoring agent"
  type        = bool
  default     = true
}

variable "node_monitoring_version" {
  description = "Node monitoring agent version"
  type        = string
  default     = "v1.2.0-eksbuild.1"
}

variable "enable_external_dns" {
  description = "Enable External DNS"
  type        = bool
  default     = false
}

variable "external_dns_version" {
  description = "External DNS version"
  type        = string
  default     = "v0.16.1-eksbuild.2"
}

variable "enable_metrics_server" {
  description = "Enable Metrics Server"
  type        = bool
  default     = true
}

variable "metrics_server_version" {
  description = "Metrics Server version"
  type        = string
  default     = "v0.7.2-eksbuild.3"
} 