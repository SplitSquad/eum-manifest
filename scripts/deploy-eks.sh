#!/bin/bash

# EKS Cluster Deployment Script
# This script deploys the EKS cluster using Terraform

set -e

# Configuration
ENVIRONMENT="${1:-dev}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform/environments/${ENVIRONMENT}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_warning "kubectl is not installed. You'll need it to manage the cluster."
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Check if Terraform directory exists
    if [ ! -d "${TERRAFORM_DIR}" ]; then
        print_error "Terraform directory for environment '${ENVIRONMENT}' does not exist: ${TERRAFORM_DIR}"
        exit 1
    fi
    
    print_status "All prerequisites met!"
}

# Function to validate Terraform configuration
validate_terraform() {
    print_status "Validating Terraform configuration..."
    cd "${TERRAFORM_DIR}"
    
    terraform fmt -check -recursive
    terraform validate
    
    print_status "Terraform configuration is valid!"
}

# Function to plan deployment
plan_deployment() {
    print_status "Planning EKS deployment for ${ENVIRONMENT} environment..."
    cd "${TERRAFORM_DIR}"
    
    terraform plan -out=tfplan
    
    echo ""
    print_warning "Please review the plan above carefully."
    read -p "Do you want to proceed with the deployment? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_status "Deployment cancelled."
        rm -f tfplan
        exit 0
    fi
}

# Function to apply deployment
apply_deployment() {
    print_status "Applying EKS deployment..."
    cd "${TERRAFORM_DIR}"
    
    terraform apply tfplan
    rm -f tfplan
    
    print_status "EKS cluster deployment completed!"
}

# Function to configure kubectl
configure_kubectl() {
    print_status "Configuring kubectl..."
    cd "${TERRAFORM_DIR}"
    
    # Get cluster name and region from Terraform output
    CLUSTER_NAME=$(terraform output -raw cluster_id 2>/dev/null || echo "")
    AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "ap-northeast-2")
    
    if [ -n "${CLUSTER_NAME}" ]; then
        aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"
        print_status "kubectl configured successfully!"
        
        # Test kubectl connection
        if kubectl cluster-info &> /dev/null; then
            print_status "Successfully connected to EKS cluster!"
            kubectl get nodes
        else
            print_warning "kubectl configuration completed, but connection test failed. The cluster might still be initializing."
        fi
    else
        print_warning "Could not retrieve cluster name from Terraform output."
    fi
}

# Function to display post-deployment information
display_info() {
    print_status "Deployment Summary:"
    cd "${TERRAFORM_DIR}"
    
    echo ""
    echo "🎉 EKS Cluster deployed successfully!"
    echo ""
    echo "📋 Cluster Information:"
    
    if terraform output cluster_id &> /dev/null; then
        echo "   Cluster Name: $(terraform output -raw cluster_id)"
    fi
    
    if terraform output cluster_endpoint &> /dev/null; then
        echo "   Cluster Endpoint: $(terraform output -raw cluster_endpoint)"
    fi
    
    if terraform output cluster_version &> /dev/null; then
        echo "   Kubernetes Version: $(terraform output -raw cluster_version)"
    fi
    
    echo ""
    echo "🔧 Next Steps:"
    echo "   1. Configure kubectl: $(terraform output -raw kubectl_config_command 2>/dev/null || echo 'aws eks update-kubeconfig --region ap-northeast-2 --name <cluster-name>')"
    echo "   2. Install necessary add-ons (AWS Load Balancer Controller, etc.)"
    echo "   3. Update ArgoCD to point to the new cluster"
    echo "   4. Deploy your applications using your existing Helm charts"
    echo ""
}

# Main execution
main() {
    echo "🚀 Starting EKS deployment for environment: ${ENVIRONMENT}"
    echo ""
    
    check_prerequisites
    
    cd "${TERRAFORM_DIR}"
    
    # Initialize Terraform if not already done
    if [ ! -d ".terraform" ]; then
        print_status "Initializing Terraform..."
        terraform init
    fi
    
    validate_terraform
    plan_deployment
    apply_deployment
    configure_kubectl
    display_info
    
    echo ""
    print_status "EKS deployment script completed!"
}

# Show usage if no arguments or help requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [environment]"
    echo ""
    echo "Arguments:"
    echo "  environment    Environment to deploy (default: dev)"
    echo ""
    echo "Examples:"
    echo "  $0 dev         Deploy to development environment"
    echo "  $0 staging     Deploy to staging environment"
    echo "  $0 prod        Deploy to production environment"
    echo ""
    exit 0
fi

# Run main function
main 