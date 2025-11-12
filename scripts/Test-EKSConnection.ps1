# PowerShell script to test EKS cluster connection
# Run this script to verify you can connect to your EKS cluster

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Testing EKS Cluster Connection" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: kubectl is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

Write-Host "1. Checking cluster info..." -ForegroundColor Yellow
kubectl cluster-info

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Cannot connect to cluster" -ForegroundColor Red
    Write-Host "Run: .\Get-EKSCredentials.ps1 -ClusterName <name> -Region <region>" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "2. Listing nodes..." -ForegroundColor Yellow
kubectl get nodes

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to list nodes" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "3. Checking current context..." -ForegroundColor Yellow
$context = kubectl config current-context
Write-Host "Current context: $context" -ForegroundColor Green

Write-Host ""
Write-Host "4. Listing namespaces..." -ForegroundColor Yellow
kubectl get namespaces

Write-Host ""
Write-Host "5. Checking ServiceAccount (if exists)..." -ForegroundColor Yellow
$sa = kubectl get serviceaccount azdo-service-account -n default 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] ServiceAccount 'azdo-service-account' exists" -ForegroundColor Green
    kubectl get serviceaccount azdo-service-account -n default
} else {
    Write-Host "[WARN] ServiceAccount 'azdo-service-account' not found" -ForegroundColor Yellow
    Write-Host "  Run: .\Get-EKSServiceAccountToken.ps1" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "[SUCCESS] Connection test completed successfully!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

