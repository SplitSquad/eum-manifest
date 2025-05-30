# EUM Terraform 설정

## 📋 개요

기존 ArgoCD 애플리케이션들을 Terraform으로 관리하기 위한 설정입니다.

## 🚀 실행 단계

### 1. 사전 준비

```powershell
# kubectl 설정 확인
kubectl config current-context
kubectl get nodes

# ArgoCD 애플리케이션 확인
kubectl get applications -n argocd
```

### 2. Terraform 초기화

```powershell
cd terraform
terraform init
```

### 3. Import 실행

```powershell
# 스크립트 실행
../scripts/import-argocd-apps.ps1

# 또는 수동으로 Import
terraform import kubectl_manifest.eum_ai_application 'apiVersion=argoproj.io/v1alpha1,kind=Application,namespace=argocd,name=eum-ai'
terraform import kubectl_manifest.eum_backend_application 'apiVersion=argoproj.io/v1alpha1,kind=Application,namespace=argocd,name=eum-backend'
terraform import kubectl_manifest.eum_infra_application 'apiVersion=argoproj.io/v1alpha1,kind=Application,namespace=argocd,name=eum-infra'
```

### 4. 계획 확인

```powershell
terraform plan
```

### 5. 적용

```powershell
terraform apply
```

## 📁 파일 구조

```
terraform/
├── providers.tf              # Provider 설정
├── variables.tf              # 변수 정의
├── argocd.tf                 # ArgoCD 설치 (선택사항)
├── argocd-applications.tf    # ArgoCD 애플리케이션들
└── README.md                 # 이 파일
```

## 🔧 주요 명령어

```powershell
# 상태 확인
terraform state list
terraform show

# 특정 리소스 상태 확인
terraform state show kubectl_manifest.eum_ai_application

# 계획 저장 및 적용
terraform plan -out=tfplan
terraform apply tfplan

# 리소스 제거 (주의!)
terraform destroy
```

## 📝 참고사항

1. **기존 ArgoCD는 건드리지 않음**: 현재 실행 중인 ArgoCD와 애플리케이션들은 그대로 유지됩니다.
2. **Import만 수행**: 기존 리소스를 Terraform 상태로만 가져옵니다.
3. **GitOps 유지**: Helm 차트는 그대로 사용하고, ArgoCD가 계속 동기화합니다.
4. **점진적 전환**: 필요에 따라 개별 애플리케이션을 Terraform으로 관리할 수 있습니다.

## ⚠️ 주의사항

- `terraform destroy`는 모든 애플리케이션을 삭제하므로 주의하세요.
- Import 전에 반드시 백업을 확인하세요.
- 상태 파일(`terraform.tfstate`)은 중요하므로 안전하게 보관하세요. 