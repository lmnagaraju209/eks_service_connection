# PowerShell script to get EKS cluster credentials for Azure DevOps Service Connection
# Run this script to configure kubectl for your EKS cluster

param(
    [Parameter(Mandatory=$true)]
    [string]$ClusterName,
    
    [Parameter(Mandatory=$true)]
    [string]$Region
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Getting EKS Cluster Credentials" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if AWS CLI is available
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: AWS CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Install from: https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: kubectl is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Install from: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Yellow
    exit 1
}

Write-Host "Updating kubeconfig for cluster: $ClusterName in region: $Region" -ForegroundColor Yellow
aws eks update-kubeconfig --name $ClusterName --region $Region

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to update kubeconfig" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Kubeconfig updated successfully" -ForegroundColor Green
Write-Host ""

# Get cluster endpoint
Write-Host "Getting cluster endpoint..." -ForegroundColor Yellow
$clusterEndpoint = aws eks describe-cluster --name $ClusterName --region $Region --query 'cluster.endpoint' --output text

if ($LASTEXITCODE -eq 0) {
    Write-Host "Cluster Endpoint: $clusterEndpoint" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to get cluster endpoint" -ForegroundColor Red
    exit 1
}

# Get cluster CA certificate
Write-Host "Getting cluster CA certificate..." -ForegroundColor Yellow
$clusterCA = aws eks describe-cluster --name $ClusterName --region $Region --query 'cluster.certificateAuthority.data' --output text

if ($LASTEXITCODE -eq 0) {
    $clusterCA | Out-File -FilePath "cluster-ca.crt" -Encoding UTF8 -NoNewline
    Write-Host "✓ CA Certificate saved to: cluster-ca.crt" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to get CA certificate" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Cluster Information" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Cluster Name: $ClusterName" -ForegroundColor White
Write-Host "Region: $Region" -ForegroundColor White
Write-Host "Endpoint: $clusterEndpoint" -ForegroundColor White
Write-Host "CA Certificate: cluster-ca.crt" -ForegroundColor White
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Test connection
Write-Host "Testing connection to cluster..." -ForegroundColor Yellow
kubectl cluster-info

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Successfully connected to EKS cluster!" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEP:" -ForegroundColor Yellow
    Write-Host "Run: .\Get-EKSServiceAccountToken.ps1" -ForegroundColor White
} else {
    Write-Host "ERROR: Failed to connect to cluster" -ForegroundColor Red
    exit 1
}

