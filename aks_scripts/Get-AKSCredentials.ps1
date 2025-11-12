# PowerShell script to get AKS cluster credentials for Azure DevOps Service Connection
# Run this script to configure kubectl for your AKS cluster

param(
    [Parameter(Mandatory=$true)]
    [string]$ClusterName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    
    [string]$SubscriptionId = ""
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Getting AKS Cluster Credentials" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is available
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Azure CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Install from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: kubectl is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Install from: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Yellow
    exit 1
}

# Check Azure CLI login status
Write-Host "Checking Azure CLI login status..." -ForegroundColor Yellow
$accountCheck = az account show 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not logged in to Azure CLI" -ForegroundColor Red
    Write-Host "Please run: az login" -ForegroundColor Yellow
    exit 1
}
Write-Host "[SUCCESS] Logged in to Azure CLI" -ForegroundColor Green

# Set subscription if provided
if ($SubscriptionId) {
    Write-Host "Setting subscription to: $SubscriptionId" -ForegroundColor Yellow
    az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to set subscription" -ForegroundColor Red
        exit 1
    }
}

# Get current subscription
$currentSub = az account show --query name -o tsv
Write-Host "Current subscription: $currentSub" -ForegroundColor Cyan
Write-Host ""

# Get AKS credentials
Write-Host "Getting AKS credentials for cluster: $ClusterName in resource group: $ResourceGroup" -ForegroundColor Yellow
az aks get-credentials --resource-group $ResourceGroup --name $ClusterName --overwrite-existing

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to get AKS credentials" -ForegroundColor Red
    Write-Host "Please verify:" -ForegroundColor Yellow
    Write-Host "  - Cluster name is correct: $ClusterName" -ForegroundColor Gray
    Write-Host "  - Resource group is correct: $ResourceGroup" -ForegroundColor Gray
    Write-Host "  - You have access to the cluster" -ForegroundColor Gray
    exit 1
}

Write-Host "[SUCCESS] AKS credentials retrieved successfully" -ForegroundColor Green
Write-Host ""

# Get cluster information
Write-Host "Getting cluster information..." -ForegroundColor Yellow
$clusterInfo = az aks show --resource-group $ResourceGroup --name $ClusterName --query "{fqdn:fqdn,kubernetesVersion:kubernetesVersion,location:location,nodeResourceGroup:nodeResourceGroup}" -o json | ConvertFrom-Json

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "AKS Cluster Information" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "Cluster Name: $ClusterName" -ForegroundColor White
    Write-Host "Resource Group: $ResourceGroup" -ForegroundColor White
    Write-Host "Location: $($clusterInfo.location)" -ForegroundColor White
    Write-Host "Kubernetes Version: $($clusterInfo.kubernetesVersion)" -ForegroundColor White
    Write-Host "FQDN: $($clusterInfo.fqdn)" -ForegroundColor White
    Write-Host "Node Resource Group: $($clusterInfo.nodeResourceGroup)" -ForegroundColor White
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "[WARN] Could not retrieve detailed cluster information" -ForegroundColor Yellow
    Write-Host ""
}

# Test connection
Write-Host "Testing connection to cluster..." -ForegroundColor Yellow
kubectl cluster-info

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[SUCCESS] Successfully connected to AKS cluster!" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEP:" -ForegroundColor Yellow
    Write-Host "Run: .\Get-AKSServiceAccountToken.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "ERROR: Failed to connect to cluster" -ForegroundColor Red
    exit 1
}

