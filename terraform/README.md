# EUM AWS EKS Infrastructure as Code

이 디렉토리는 EUM 프로젝트의 AWS EKS 인프라를 Terraform으로 관리합니다.

## 📁 구조

```
terraform/
├── environments/           # 환경별 설정
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/               # 재사용 가능한 Terraform 모듈
│   ├── eks/              # EKS 클러스터 모듈
│   ├── vpc/              # VPC 및 네트워킹 모듈
│   ├── iam/              # IAM 역할 및 정책 모듈
│   └── security-groups/  # 보안 그룹 모듈
├── scripts/              # 헬퍼 스크립트
└── shared/              # 공통 설정
```

## 🚀 사용법

### 초기 설정
```bash
# 특정 환경으로 이동
cd environments/dev

# Terraform 초기화
terraform init

# 계획 확인
terraform plan -var-file="terraform.tfvars"

# 적용
terraform apply -var-file="terraform.tfvars"
```

### 환경별 배포
- **dev**: 개발 환경 (작은 리소스, 실험용)
- **staging**: 스테이징 환경 (프로덕션과 유사한 설정)
- **prod**: 프로덕션 환경 (HA, 보안 강화)

## ⚠️ 주의사항

1. **백엔드 상태 관리**: S3 + DynamoDB 사용
2. **IAM 권한**: 최소 권한 원칙 적용
3. **네트워크 보안**: Private 서브넷에 워커 노드 배치
4. **버전 관리**: 특정 버전 고정으로 일관성 유지 