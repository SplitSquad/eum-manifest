# 변수 설정
$RELEASE_NAME = "eum-backend-helm"
$NAMESPACE = "eum-backend"

Write-Host "Starting Helm migration process for eum-backend..." -ForegroundColor Green

# 모든 서비스별 리소스 타입과 이름 정의
$resources = @(
    @{type="configmap"; names=@("user-config", "debate-config", "community-config", "information-config", "log-config", "api-gateway-config", "alarm-config")},
    @{type="deployment"; names=@("user", "debate", "community", "information", "log", "api-gateway", "alarm", "eureka-server")},
    @{type="service"; names=@("user", "debate", "community", "information", "log", "api-gateway", "alarm", "eureka-server")}
)

# 각 리소스에 Helm 메타데이터 추가
foreach ($resourceType in $resources) {
    Write-Host "Processing $($resourceType.type) resources..." -ForegroundColor Yellow
    foreach ($name in $resourceType.names) {
        Write-Host "  - Adding Helm metadata to $($resourceType.type) $name..." -ForegroundColor Cyan
        
        kubectl label $resourceType.type $name -n $NAMESPACE app.kubernetes.io/managed-by=Helm --overwrite
        kubectl annotate $resourceType.type $name -n $NAMESPACE meta.helm.sh/release-name=$RELEASE_NAME --overwrite
        kubectl annotate $resourceType.type $name -n $NAMESPACE meta.helm.sh/release-namespace=$NAMESPACE --overwrite
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✓ Successfully processed $name" -ForegroundColor Green
        } else {
            Write-Host "    ✗ Failed to process $name" -ForegroundColor Red
        }
    }
}

Write-Host "Helm migration metadata setup completed for eum-backend!" -ForegroundColor Green
Write-Host "Now you can run: helm install eum-backend-helm ./helm-charts/eum-backend --namespace eum-backend" -ForegroundColor Yellow 