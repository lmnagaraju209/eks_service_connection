# Azure AKS Scripts (Windows/PowerShell)

PowerShell scripts to create and manage service connections from Azure DevOps to **Azure Kubernetes Service (AKS)**.

## 📁 Files

| File | Description |
|------|-------------|
| `Get-AKSCredentials.ps1` | Configure kubectl for your AKS cluster |
| `Get-AKSServiceAccountToken.ps1` | Create ServiceAccount and extract connection details |
| `Test-AKSConnection.ps1` | Test AKS cluster connectivity |
| `Remove-AKSServiceAccount.ps1` | Clean up ServiceAccount resources |
| `Create-AKSServiceAccount.yaml` | Kubernetes manifest for ServiceAccount and RBAC |
| `.gitignore` | Protects sensitive credential files |

## 🚀 Quick Start

### Step 1: Login to Azure

```powershell
# Login to Azure CLI
az login

# Verify login
az account show

# Set subscription (if needed)
az account set --subscription "Your-Subscription-Name"
```

### Step 2: Get AKS Credentials

```powershell
# Find your cluster and resource group
az aks list --output table

# Get credentials
.\Get-AKSCredentials.ps1 -ClusterName "AZAMERES01KUB14031NP01" -ResourceGroup "your-resource-group"
```

### Step 3: Create ServiceAccount and Extract Token

```powershell
.\Get-AKSServiceAccountToken.ps1
```

This will create three files:
- `cluster-endpoint.txt`
- `cluster-ca-cert-base64.txt`
- `service-account-token.txt`

### Step 4: Create Service Connection in Azure DevOps

1. Go to: https://dev.azure.com/MetLife-Global/Elastic-Cloud/_settings/adminservices
2. Click: "New service connection" → "Kubernetes"
3. Select: "Service Account" authentication
4. Copy values from the generated text files
5. Service connection name: `AKS-Mosaik-Production`
6. Click: "Verify and save"

### Step 5: Test (Optional)

```powershell
.\Test-AKSConnection.ps1
```

## 📋 Prerequisites

- Windows 10/11 with PowerShell
- [Azure CLI](https://aka.ms/installazurecliwindows) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) installed
- Azure subscription with AKS access
- Admin access to Azure DevOps project

## 🔧 Script Parameters

### Get-AKSCredentials.ps1

```powershell
.\Get-AKSCredentials.ps1 -ClusterName <name> -ResourceGroup <rg> [-SubscriptionId <id>]
```

**Parameters:**
- `-ClusterName` (required): AKS cluster name
- `-ResourceGroup` (required): Azure resource group name
- `-SubscriptionId` (optional): Azure subscription ID

### Get-AKSServiceAccountToken.ps1

```powershell
.\Get-AKSServiceAccountToken.ps1 [-Namespace <namespace>] [-ServiceAccountName <name>] [-SecretName <name>]
```

**Parameters:**
- `-Namespace` (optional, default: "default"): Kubernetes namespace
- `-ServiceAccountName` (optional, default: "azdo-service-account"): ServiceAccount name
- `-SecretName` (optional, default: "azdo-service-account-token"): Secret name

### Remove-AKSServiceAccount.ps1

```powershell
.\Remove-AKSServiceAccount.ps1 [-Namespace <namespace>] [-Force]
```

**Parameters:**
- `-Namespace` (optional, default: "default"): Kubernetes namespace
- `-Force` (optional): Skip confirmation prompt

## 🔍 Troubleshooting

### Error: "Azure CLI not found"

```powershell
# Install Azure CLI
# Download from: https://aka.ms/installazurecliwindows

# Verify installation
az --version
```

### Error: "Not logged in to Azure CLI"

```powershell
# Login
az login

# List subscriptions
az account list --output table

# Set subscription
az account set --subscription "Your-Subscription-Name"
```

### Error: "kubectl not found"

```powershell
# Install kubectl via Azure CLI
az aks install-cli

# Or download from Kubernetes
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

### Error: "Cannot connect to cluster"

```powershell
# List AKS clusters
az aks list --output table

# Get credentials again
az aks get-credentials --name <cluster-name> --resource-group <rg-name> --overwrite-existing

# Verify connection
kubectl cluster-info
```

### Error: "Access Denied"

```powershell
# Check your role assignments
az role assignment list --resource-group <rg-name> --assignee <your-email>

# You need one of these roles:
# - Azure Kubernetes Service Cluster User Role
# - Azure Kubernetes Service Cluster Admin Role
# - Contributor or Owner on the resource group
```

## 💡 Common Azure CLI Commands

```powershell
# List all AKS clusters
az aks list --output table

# Get cluster details
az aks show --name <cluster-name> --resource-group <rg-name>

# List resource groups
az group list --output table

# Find resource groups with AKS clusters
az group list --query "[?contains(name,'kub') || contains(name,'aks')].name" --output table

# Get current subscription
az account show

# List all subscriptions
az account list --output table
```

## 🔐 Security Notes

### Sensitive Files Created:
- `cluster-endpoint.txt`
- `cluster-ca-cert-base64.txt`
- `service-account-token.txt`

**⚠️ IMPORTANT:** These files contain cluster credentials. 

**After creating the service connection:**
```powershell
# Delete sensitive files
Remove-Item cluster-*.txt, service-account-token.txt
```

### RBAC Permissions

The default setup uses `cluster-admin` role which grants full cluster access. For production environments, consider using more restrictive permissions:

```yaml
# Example: Namespace-specific RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: azdo-deployer
  namespace: production
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployer
subjects:
- kind: ServiceAccount
  name: azdo-service-account
  namespace: default
```

## 📝 Example Workflow

```powershell
# Complete setup from start to finish

# 1. Login to Azure
az login
az account set --subscription "Production"

# 2. Navigate to scripts
cd D:\rathan_reddy\Mosaik\eks_service_connection\aks_scripts

# 3. Get AKS credentials
.\Get-AKSCredentials.ps1 -ClusterName "prod-aks-cluster" -ResourceGroup "rg-prod-aks"

# 4. Create ServiceAccount and get token
.\Get-AKSServiceAccountToken.ps1

# 5. View the files
notepad cluster-endpoint.txt
notepad service-account-token.txt

# 6. Test connection
.\Test-AKSConnection.ps1

# 7. After creating service connection in Azure DevOps, cleanup
Remove-Item cluster-*.txt, service-account-token.txt
```

## 🧹 Cleanup

To remove the ServiceAccount from AKS:

```powershell
.\Remove-AKSServiceAccount.ps1
```

Then delete the service connection in Azure DevOps:
- Project Settings → Service connections → Delete

## 📚 Additional Resources

- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [AKS Documentation](https://docs.microsoft.com/azure/aks/)
- [Azure DevOps Kubernetes Connection](https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints)
- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

## ✅ Success Checklist

- [ ] Azure CLI installed
- [ ] kubectl installed
- [ ] Logged in to Azure CLI
- [ ] Subscription set correctly
- [ ] AKS cluster name and resource group known
- [ ] AKS credentials retrieved
- [ ] ServiceAccount created
- [ ] Token files generated
- [ ] Service connection created in Azure DevOps
- [ ] Service connection verified and working
- [ ] Sensitive files deleted locally

---

**Need help?** See the parent folder's [AZURE-AKS-QUICK-START.md](../AZURE-AKS-QUICK-START.md) for a complete walkthrough.

