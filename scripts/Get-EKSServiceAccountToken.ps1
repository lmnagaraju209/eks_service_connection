# PowerShell script to get EKS ServiceAccount token for Azure DevOps
# Run this script to extract connection details for Azure DevOps Service Connection

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
    Write-Host "Install from: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Yellow
    exit 1
}

# Check if connected to cluster
Write-Host "Verifying connection to cluster..." -ForegroundColor Yellow
$clusterInfo = kubectl cluster-info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not connected to Kubernetes cluster" -ForegroundColor Red
    Write-Host "Run: .\Get-EKSCredentials.ps1 -ClusterName <name> -Region <region>" -ForegroundColor Yellow
    exit 1
}
Write-Host "[SUCCESS] Connected to cluster" -ForegroundColor Green
Write-Host ""

# Check if ServiceAccount YAML file exists
if (-not (Test-Path "Create-EKSServiceAccount.yaml")) {
    Write-Host "ERROR: Create-EKSServiceAccount.yaml not found" -ForegroundColor Red
    Write-Host "Make sure you're running this script from the scripts folder" -ForegroundColor Yellow
    exit 1
}

# Apply the ServiceAccount YAML
Write-Host "Creating ServiceAccount and RBAC..." -ForegroundColor Yellow
kubectl apply -f Create-EKSServiceAccount.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create ServiceAccount" -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] ServiceAccount created successfully" -ForegroundColor Green
Write-Host ""

# Wait for secret to be created
Write-Host "Waiting for token secret to be created..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verify secret exists
$secretExists = kubectl get secret $SecretName -n $Namespace 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Secret '$SecretName' not found" -ForegroundColor Red
    Write-Host "The secret may not have been created automatically (Kubernetes 1.24+)" -ForegroundColor Yellow
    exit 1
}
Write-Host "[SUCCESS] Secret found" -ForegroundColor Green
Write-Host ""

# Get the token
Write-Host "Extracting token..." -ForegroundColor Yellow
$tokenBase64 = kubectl get secret $SecretName -n $Namespace -o jsonpath='{.data.token}'
if (-not $tokenBase64) {
    Write-Host "ERROR: Failed to get token from secret" -ForegroundColor Red
    exit 1
}

try {
    $decodedToken = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($tokenBase64))
    Write-Host "[SUCCESS] Token extracted" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to decode token" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Get the CA certificate
Write-Host "Extracting CA certificate..." -ForegroundColor Yellow
$caCert = kubectl get secret $SecretName -n $Namespace -o jsonpath='{.data.ca\.crt}'
if (-not $caCert) {
    Write-Host "ERROR: Failed to get CA certificate" -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] CA certificate extracted" -ForegroundColor Green

# Get cluster endpoint
Write-Host "Getting cluster endpoint..." -ForegroundColor Yellow
$clusterEndpoint = kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
if (-not $clusterEndpoint) {
    Write-Host "ERROR: Failed to get cluster endpoint" -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] Cluster endpoint retrieved" -ForegroundColor Green
Write-Host ""

# Display results
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
try {
    $clusterEndpoint | Out-File -FilePath "cluster-endpoint.txt" -Encoding UTF8 -NoNewline
    $caCert | Out-File -FilePath "cluster-ca-cert-base64.txt" -Encoding UTF8 -NoNewline
    $decodedToken | Out-File -FilePath "service-account-token.txt" -Encoding UTF8 -NoNewline
    
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "Files Saved to Current Directory:" -ForegroundColor Green
    Write-Host "  [OK] cluster-endpoint.txt" -ForegroundColor Cyan
    Write-Host "  [OK] cluster-ca-cert-base64.txt" -ForegroundColor Cyan
    Write-Host "  [OK] service-account-token.txt" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to save files" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║                        NEXT STEPS                              ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to Azure DevOps:" -ForegroundColor White
Write-Host "   https://dev.azure.com/MetLife-Global/Elastic-Cloud/_settings/adminservices" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Click: 'New service connection' → 'Kubernetes'" -ForegroundColor White
Write-Host ""
Write-Host "3. Select: 'Service Account' authentication method" -ForegroundColor White
Write-Host ""
Write-Host "4. Fill in the form:" -ForegroundColor White
Write-Host "   • Server URL: Copy from cluster-endpoint.txt" -ForegroundColor Gray
Write-Host "   • Secret: Copy from service-account-token.txt" -ForegroundColor Gray
Write-Host "   • Service connection name: EKS-Mosaik-Production" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Click: 'Verify and save'" -ForegroundColor White
Write-Host ""
Write-Host "6. Use in your pipeline:" -ForegroundColor White
Write-Host "   service_connection: 'EKS-Mosaik-Production'" -ForegroundColor Gray
Write-Host ""

# Copy to clipboard helper (optional)
if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
    Write-Host "TIP: Files are saved. You can also copy values:" -ForegroundColor Yellow
    Write-Host "  Get-Content cluster-endpoint.txt | Set-Clipboard" -ForegroundColor Gray
    Write-Host ""
}
