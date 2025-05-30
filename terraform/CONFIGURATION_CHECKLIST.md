# 🔧 EUM Terraform 설정 체크리스트

실제 환경에 맞게 **반드시 수정해야 할** 설정 항목들입니다.

## ✅ 1. 환경별 기본 설정

### 📍 위치: `terraform/environments/dev/variables.tf`

```hcl
# 🔧 AWS 기본 설정
variable "aws_region" {
  default = "ap-northeast-2"  # ← 실제 사용 리전 확인
}

variable "project_name" {
  default = "eum"  # ← 프로젝트명 확인
}
```

## ✅ 2. 노드 그룹 설정 (가장 중요!)

### 📍 위치: `terraform/environments/dev/variables.tf` (76~102라인)

```hcl
variable "node_groups" {
  default = {
    main = {
      instance_types = ["t3.2xlarge"]  # ✅ 이미 수정됨
      disk_size      = 40              # ✅ 이미 수정됨
      desired_size   = 2               # 🔧 원하는 노드 수로 변경
      max_size       = 3               # ✅ 이미 수정됨
      min_size       = 1               # 🔧 최소 노드 수 설정
      ec2_ssh_key    = ""              # ✅ 선택사항 (비워도 됨)
    }
  }
}
```

**✅ SSH 키는 이제 선택사항입니다!**

## ✅ 3. 네트워크 설정

### 📍 위치: `terraform/environments/dev/variables.tf` (18~34라인)

```hcl
variable "vpc_cidr" {
  default = "10.0.0.0/16"  # 🔧 기존 VPC와 겹치지 않는지 확인
}

variable "public_subnet_cidrs" {
  default = ["10.0.0.0/20", "10.0.16.0/20"]  # ✅ 업데이트됨
}

variable "private_subnet_cidrs" {
  default = ["10.0.128.0/20", "10.0.144.0/20"]  # ✅ 업데이트됨
}

variable "public_access_cidrs" {
  default = ["0.0.0.0/0"]  # 🔧 보안을 위해 회사 IP로 제한 권장
}
```

## ✅ 4. EKS 애드온 설정 (실제 환경 반영)

### 📍 위치: `terraform/environments/dev/variables.tf` (109~176라인)

**기본 애드온 버전 (실제 환경과 일치):**
```hcl
# ✅ 업데이트된 버전들
variable "coredns_version" {
  default = "v1.11.4-eksbuild.2"  # 실제: v1.11.4-eksbuild.2
}

variable "kube_proxy_version" {
  default = "v1.32.0-eksbuild.2"  # 실제: v1.32.0-eksbuild.2  
}

variable "vpc_cni_version" {
  default = "v1.19.2-eksbuild.1"  # 실제: v1.19.2-eksbuild.1
}

variable "ebs_csi_version" {
  default = "v1.43.0-eksbuild.1"  # 실제: v1.43.0-eksbuild.1
}
```

**추가 애드온 설정:**
```hcl
# ✅ 실제 환경에서 활성화된 애드온들
variable "enable_pod_identity" {
  default = true  # EKS Pod Identity 에이전트
}

variable "enable_node_monitoring" {
  default = true  # 노드 모니터링 에이전트
}

variable "enable_metrics_server" {
  default = true  # 지표 서버 (HPA/VPA 사용 시 필수)
}

variable "enable_external_dns" {
  default = false  # 🔧 필요시 true로 변경
}
```

## ✅ 5. 백엔드 설정 (S3 + DynamoDB)

### 📍 위치: `terraform/environments/dev/backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "eum-terraform-state-dev"  # 🔧 유니크한 버킷명으로 변경
    dynamodb_table = "eum-terraform-locks"      # 🔧 테이블명 확인
    region         = "ap-northeast-2"           # 🔧 실제 리전 확인
  }
}
```

## 🚀 배포 전 체크리스트

- [ ] **회사 공인 IP 확인** (`public_access_cidrs` 설정용)
- [ ] **VPC CIDR 충돌 확인** (기존 인프라와 겹치지 않는지)
- [ ] **S3 버킷명 유니크성 확인** (전 세계적으로 유일해야 함)
- [ ] **AWS 권한 확인** (EKS, VPC, IAM 생성 권한)
- [ ] **애드온 설정 확인** (External DNS 필요 여부)

## 📋 실행 순서

1. **설정 파일 수정** (위 체크리스트 완료)
2. **백엔드 설정**
   ```bash
   ./scripts/setup-terraform-backend.sh
   ```
3. **EKS 배포**
   ```bash
   ./scripts/deploy-eks.sh dev
   ```

## ⚠️ 주의사항

1. **S3 버킷명**: 전 세계적으로 유일해야 함 (예: `eum-terraform-state-dev-20240101`)
2. **비용**: t3.2xlarge는 비용이 높으니 개발환경에서는 t3.medium 사용 고려
3. **보안**: `public_access_cidrs`를 `0.0.0.0/0`으로 두면 보안 위험
4. **애드온**: External DNS는 Route53 권한이 필요할 수 있음

## 🆕 새로 추가된 기능들

1. **SSH 키 선택사항**: `ec2_ssh_key`를 비워둬도 배포 가능
2. **조건부 애드온**: 필요한 애드온만 선택적으로 활성화
3. **실제 환경 버전**: 모든 애드온 버전이 실제 환경과 일치
4. **더 큰 서브넷**: `/20` CIDR로 더 많은 IP 할당

## 🔍 설정 확인 명령어

```bash
# 현재 AWS 계정 확인
aws sts get-caller-identity

# 키페어 목록 확인 (선택사항)
aws ec2 describe-key-pairs --region ap-northeast-2

# 공인 IP 확인
curl ifconfig.me
```

## 📊 실제 환경 vs Terraform 매핑

| 실제 애드온 | Terraform 변수 | 상태 |
|------------|---------------|------|
| EKS Pod Identity 에이전트 | `enable_pod_identity = true` | ✅ 활성화 |
| Amazon EBS CSI 드라이버 | 기본 포함 | ✅ 활성화 |
| 노드 모니터링 에이전트 | `enable_node_monitoring = true` | ✅ 활성화 |
| CoreDNS | 기본 포함 | ✅ 활성화 |
| External DNS | `enable_external_dns = false` | 🔧 필요시 활성화 |
| 지표 서버 | `enable_metrics_server = true` | ✅ 활성화 |
| kube-proxy | 기본 포함 | ✅ 활성화 |
| Amazon VPC CNI | 기본 포함 | ✅ 활성화 | 