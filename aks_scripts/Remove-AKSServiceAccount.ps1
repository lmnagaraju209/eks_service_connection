# PowerShell script to remove the Azure DevOps ServiceAccount from AKS
# Run this script to clean up the ServiceAccount, ClusterRoleBinding, and Secret

param(
    [string]$Namespace = "default",
    [switch]$Force
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Remove Azure DevOps ServiceAccount from AKS" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

if (-not $Force) {
    Write-Host "WARNING: This will remove the following resources:" -ForegroundColor Yellow
    Write-Host "  - ServiceAccount: azdo-service-account" -ForegroundColor Gray
    Write-Host "  - ClusterRoleBinding: azdo-cluster-admin" -ForegroundColor Gray
    Write-Host "  - Secret: azdo-service-account-token" -ForegroundColor Gray
    Write-Host ""
    
    $confirmation = Read-Host "Are you sure you want to continue? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Host "Cancelled" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "Removing resources..." -ForegroundColor Yellow

# Delete ServiceAccount YAML
if (Test-Path "Create-AKSServiceAccount.yaml") {
    kubectl delete -f Create-AKSServiceAccount.yaml
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] Resources removed successfully" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Some resources may not exist or failed to delete" -ForegroundColor Yellow
    }
} else {
    Write-Host "Removing resources individually..." -ForegroundColor Yellow
    
    # Delete Secret
    kubectl delete secret azdo-service-account-token -n $Namespace 2>&1 | Out-Null
    
    # Delete ClusterRoleBinding
    kubectl delete clusterrolebinding azdo-cluster-admin 2>&1 | Out-Null
    
    # Delete ServiceAccount
    kubectl delete serviceaccount azdo-service-account -n $Namespace 2>&1 | Out-Null
    
    Write-Host "[SUCCESS] Cleanup completed" -ForegroundColor Green
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Cleanup Complete" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Remember to also delete the service connection in Azure DevOps:" -ForegroundColor Yellow
Write-Host "Project Settings -> Service connections -> Delete connection" -ForegroundColor Gray

