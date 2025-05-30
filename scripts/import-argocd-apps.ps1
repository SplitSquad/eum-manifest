#!/usr/bin/env powershell

# ArgoCD Applications Import Script
# 기존 ArgoCD 애플리케이션들을 Terraform으로 Import하는 스크립트

Write-Host "=== ArgoCD Applications Import Script ===" -ForegroundColor Green

# Terraform 디렉토리로 이동
Set-Location terraform

# Terraform 초기화
Write-Host "Terraform 초기화 중..." -ForegroundColor Yellow
terraform init

# 기존 애플리케이션들 확인
Write-Host "기존 ArgoCD 애플리케이션들 확인 중..." -ForegroundColor Yellow
kubectl get applications -n argocd

Write-Host "`n현재 배포된 애플리케이션들을 Terraform으로 Import합니다." -ForegroundColor Cyan

# Import 명령어들
$importCommands = @(
    "terraform import kubectl_manifest.eum_ai_application 'apiVersion=argoproj.io/v1alpha1,kind=Application,namespace=argocd,name=eum-ai'",
    "terraform import kubectl_manifest.eum_backend_application 'apiVersion=argoproj.io/v1alpha1,kind=Application,namespace=argocd,name=eum-backend'",
    "terraform import kubectl_manifest.eum_infra_application 'apiVersion=argoproj.io/v1alpha1,kind=Application,namespace=argocd,name=eum-infra'"
)

foreach ($command in $importCommands) {
    Write-Host "실행 중: $command" -ForegroundColor Yellow
    try {
        Invoke-Expression $command
        Write-Host "✅ 성공" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ 실패: $_" -ForegroundColor Red
    }
    Write-Host ""
}

# Plan 실행하여 확인
Write-Host "Terraform Plan 실행 중..." -ForegroundColor Yellow
terraform plan

Write-Host "`n=== Import 완료 ===" -ForegroundColor Green
Write-Host "다음 명령어로 상태를 확인하세요:" -ForegroundColor Cyan
Write-Host "terraform state list" -ForegroundColor White
Write-Host "terraform show" -ForegroundColor White 