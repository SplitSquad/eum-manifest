#!/bin/bash

# Terraform Backend Setup Script
# This script creates the necessary AWS resources for Terraform state management

set -e

# Configuration
PROJECT_NAME="eum"
ENVIRONMENT="dev"
AWS_REGION="ap-northeast-2"
S3_BUCKET_NAME="${PROJECT_NAME}-terraform-state-${ENVIRONMENT}"
DYNAMODB_TABLE_NAME="${PROJECT_NAME}-terraform-locks"

echo "🚀 Setting up Terraform backend for ${PROJECT_NAME}..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS CLI is properly configured"

# Create S3 bucket for Terraform state
echo "📦 Creating S3 bucket: ${S3_BUCKET_NAME}"
if aws s3api head-bucket --bucket "${S3_BUCKET_NAME}" 2>/dev/null; then
    echo "⚠️  S3 bucket ${S3_BUCKET_NAME} already exists"
else
    aws s3api create-bucket \
        --bucket "${S3_BUCKET_NAME}" \
        --region "${AWS_REGION}" \
        --create-bucket-configuration LocationConstraint="${AWS_REGION}"
    echo "✅ S3 bucket created successfully"
fi

# Enable versioning on S3 bucket
echo "🔄 Enabling versioning on S3 bucket"
aws s3api put-bucket-versioning \
    --bucket "${S3_BUCKET_NAME}" \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
echo "🔒 Enabling server-side encryption on S3 bucket"
aws s3api put-bucket-encryption \
    --bucket "${S3_BUCKET_NAME}" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block public access
echo "🚫 Blocking public access on S3 bucket"
aws s3api put-public-access-block \
    --bucket "${S3_BUCKET_NAME}" \
    --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Create DynamoDB table for state locking
echo "🗂️  Creating DynamoDB table: ${DYNAMODB_TABLE_NAME}"
if aws dynamodb describe-table --table-name "${DYNAMODB_TABLE_NAME}" --region "${AWS_REGION}" &>/dev/null; then
    echo "⚠️  DynamoDB table ${DYNAMODB_TABLE_NAME} already exists"
else
    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE_NAME}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
        --region "${AWS_REGION}"
    
    echo "⏳ Waiting for DynamoDB table to become active..."
    aws dynamodb wait table-exists --table-name "${DYNAMODB_TABLE_NAME}" --region "${AWS_REGION}"
    echo "✅ DynamoDB table created successfully"
fi

echo ""
echo "🎉 Terraform backend setup completed!"
echo ""
echo "📋 Summary:"
echo "   S3 Bucket: ${S3_BUCKET_NAME}"
echo "   DynamoDB Table: ${DYNAMODB_TABLE_NAME}"
echo "   Region: ${AWS_REGION}"
echo ""
echo "🔧 Next steps:"
echo "   1. Update the backend configuration in terraform/environments/${ENVIRONMENT}/backend.tf"
echo "   2. Run 'terraform init' in the environment directory"
echo "   3. Run 'terraform plan' to review the infrastructure changes"
echo "   4. Run 'terraform apply' to create the EKS cluster"
echo "" 