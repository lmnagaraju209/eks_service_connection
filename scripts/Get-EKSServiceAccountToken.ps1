# PowerShell script to get EKS ServiceAccount token for Azure DevOps
# Run this on Windows

param(
    [string]$Namespace = "default",
    [string]$ServiceAccountName = "azdo-service-account",
    [string]$SecretName = "azdo-service-account-token"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Getting EKS ServiceAccount Token for Azure DevOps" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: kubectl is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Apply the ServiceAccount YAML
Write-Host "Creating ServiceAccount and RBAC..." -ForegroundColor Yellow
kubectl apply -f create-eks-serviceaccount.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create ServiceAccount" -ForegroundColor Red
    exit 1
}

# Wait for secret to be created
Write-Host "Waiting for token secret to be created..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Get the token
Write-Host "Extracting token..." -ForegroundColor Yellow
$token = kubectl get secret $SecretName -n $Namespace -o jsonpath='{.data.token}'
if ($token) {
    $decodedToken = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token))
} else {
    Write-Host "ERROR: Failed to get token" -ForegroundColor Red
    exit 1
}

# Get the CA certificate
Write-Host "Extracting CA certificate..." -ForegroundColor Yellow
$caCert = kubectl get secret $SecretName -n $Namespace -o jsonpath='{.data.ca\.crt}'

# Get cluster endpoint
Write-Host "Getting cluster endpoint..." -ForegroundColor Yellow
$clusterEndpoint = kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "EKS Cluster Connection Details" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Server URL (Cluster Endpoint):" -ForegroundColor Yellow
Write-Host $clusterEndpoint -ForegroundColor White
Write-Host ""

Write-Host "CA Certificate (base64):" -ForegroundColor Yellow
Write-Host $caCert -ForegroundColor White
Write-Host ""

Write-Host "Service Account Token:" -ForegroundColor Yellow
Write-Host $decodedToken -ForegroundColor White
Write-Host ""

# Save to files
$clusterEndpoint | Out-File -FilePath "cluster-endpoint.txt" -Encoding UTF8
$caCert | Out-File -FilePath "cluster-ca-cert-base64.txt" -Encoding UTF8
$decodedToken | Out-File -FilePath "service-account-token.txt" -Encoding UTF8

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Files Saved:" -ForegroundColor Green
Write-Host "  ✓ cluster-endpoint.txt" -ForegroundColor Cyan
Write-Host "  ✓ cluster-ca-cert-base64.txt" -ForegroundColor Cyan
Write-Host "  ✓ service-account-token.txt" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Go to Azure DevOps → Project Settings → Service connections" -ForegroundColor White
Write-Host "2. Click 'New service connection' → 'Kubernetes'" -ForegroundColor White
Write-Host "3. Select 'Service Account' authentication" -ForegroundColor White
Write-Host "4. Use the values above to fill in the form" -ForegroundColor White
Write-Host "5. Click 'Verify and save'" -ForegroundColor White
Write-Host ""

