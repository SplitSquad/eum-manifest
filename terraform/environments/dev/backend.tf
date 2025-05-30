terraform {
  backend "s3" {
    # 🔧 Terraform 전용 S3 버킷 (애플리케이션용 'eum-msa-bucket'과는 별개!)
    bucket         = "eum-terraform-state-dev"          # 🔧 실제 S3 버킷 이름으로 변경
    key            = "eks/dev/terraform.tfstate"         # 상태 파일 경로
    region         = "ap-northeast-2"                    # 🔧 실제 사용하는 AWS 리전
    
    # 🔧 Terraform 상태 잠금용 DynamoDB 테이블 (애플리케이션 DB와는 별개!)
    dynamodb_table = "eum-terraform-locks"               # 🔧 실제 DynamoDB 테이블 이름
    encrypt        = true                                # 암호화 활성화
    
    # 추가 보안을 위한 설정
    # versioning을 활성화한 S3 버킷 사용 권장
    # MFA delete 활성화 권장
  }
}

# 📝 중요: 이 백엔드는 Terraform 전용입니다!
# ┌─────────────────────────────────────────────────────┐
# │ 애플리케이션용 S3 (기존): eum-msa-bucket            │
# │ - 용도: 이미지 업로드, 파일 저장                     │
# │ - 이미 사용 중                                      │
# │                                                     │
# │ Terraform 백엔드용 S3 (신규): eum-terraform-state   │
# │ - 용도: Terraform 상태 파일 저장                    │
# │ - 새로 생성 필요                                    │
# └─────────────────────────────────────────────────────┘

# 🔧 백엔드 설정 사용 전 필요한 리소스들 (스크립트로 자동 생성됨):
# 1. S3 버킷 생성 (버전 관리 활성화) - Terraform 전용
# 2. DynamoDB 테이블 생성 (LockID 기본 키) - 상태 잠금용
# 3. 적절한 IAM 권한 설정

# 🔧 초기 설정 스크립트 실행:
# ./scripts/setup-terraform-backend.sh

# 수동 설정이 필요한 경우:
# aws s3 mb s3://eum-terraform-state-dev --region ap-northeast-2
# aws s3api put-bucket-versioning --bucket eum-terraform-state-dev --versioning-configuration Status=Enabled
# aws dynamodb create-table --table-name eum-terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 --region ap-northeast-2 