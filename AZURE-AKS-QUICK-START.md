# Quick Start: Azure DevOps to Azure AKS Service Connection (Windows)

## 🚀 Fast Setup (5 Minutes)

### Prerequisites
- Azure CLI installed and configured
- kubectl installed
- PowerShell (comes with Windows)
- Access to AKS cluster
- Admin access to Azure DevOps project

---

## Step-by-Step Guide

### 1️⃣ Login to Azure CLI

Open PowerShell:

```powershell
# Login to Azure
az login

# Set your subscription (if you have multiple)
az account set --subscription "Your-Subscription-Name"

# Verify
az account show
```

### 2️⃣ Configure kubectl for AKS

Navigate to the aks_scripts folder and get AKS credentials:

```powershell
cd D:\rathan_reddy\Mosaik\eks_service_connection\aks_scripts

# Get AKS credentials
.\Get-AKSCredentials.ps1 -ClusterName "your-aks-cluster-name" -ResourceGroup "your-resource-group"

# Example:
.\Get-AKSCredentials.ps1 -ClusterName "AZAMERES01KUB14031NP01" -ResourceGroup "rg-aks-prod"
```

**✓ This will:**
- Get AKS credentials and update kubeconfig
- Verify connection to AKS
- Display cluster information

### 3️⃣ Create ServiceAccount and Get Token

```powershell
.\Get-AKSServiceAccountToken.ps1
```

**✓ This will:**
- Create ServiceAccount in AKS cluster
- Extract connection details
- Save to text files:
  - `cluster-endpoint.txt`
  - `cluster-ca-cert-base64.txt`
  - `service-account-token.txt`

### 4️⃣ Create Service Connection in Azure DevOps

1. **Go to:** [Azure DevOps Service Connections](https://dev.azure.com/MetLife-Global/Elastic-Cloud/_settings/adminservices)

2. **Click:** "New service connection" → **"Kubernetes"**

3. **Select:** "Service Account" authentication

4. **Fill in the form:**
   
   Open the saved files and copy values:
   
   ```powershell
   # To view the files:
   notepad cluster-endpoint.txt
   notepad service-account-token.txt
   ```
   
   | Field | File to Copy From |
   |-------|------------------|
   | **Server URL** | `cluster-endpoint.txt` |
   | **Secret** | `service-account-token.txt` |
   | **Service connection name** | `AKS-Mosaik-Production` |

5. **Check:** "Grant access permission to all pipelines"

6. **Click:** "Verify and save"

### 5️⃣ Update Your Pipeline

Now you can use the service connection in your pipeline:

```yaml
parameters:
- name: service_connection
  type: string
  displayName: 'Service Connection'
  default: 'AKS-Mosaik-Production'

steps:
  - task: Kubernetes@1
    inputs:
      connectionType: 'Kubernetes Service Connection'
      kubernetesServiceEndpoint: '${{parameters.service_connection}}'
      command: 'apply'
      arguments: '-f deployment.yaml'
```

### 6️⃣ Test the Connection (Optional)

```powershell
.\Test-AKSConnection.ps1
```

---

## 📁 Files Created

In the `aks_scripts` folder, you'll find:
- ✅ `cluster-endpoint.txt` - Server URL for Azure DevOps
- ✅ `cluster-ca-cert-base64.txt` - CA certificate (base64)
- ✅ `service-account-token.txt` - Authentication token

**⚠️ Important:** These files contain sensitive information. Don't commit them to source control!

---

## 🔍 Troubleshooting

### Issue: "Azure CLI not found"
```powershell
# Check if Azure CLI is installed
az --version

# If not, download from:
# https://aka.ms/installazurecliwindows
```

### Issue: "kubectl not found"
```powershell
# Check if kubectl is installed
kubectl version --client

# If not, install via Azure CLI:
az aks install-cli

# Or download from:
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

### Issue: "Not logged in to Azure CLI"
```powershell
# Login to Azure
az login

# List subscriptions
az account list --output table

# Set subscription
az account set --subscription "Your-Subscription-Name"
```

### Issue: "Cannot connect to cluster"
```powershell
# Verify AKS cluster exists
az aks list --output table

# Get credentials again
az aks get-credentials --resource-group <rg-name> --name <cluster-name> --overwrite-existing

# Test connection
kubectl cluster-info
```

### Issue: "Access Denied" to AKS cluster
```powershell
# Check your role in the resource group
az role assignment list --resource-group <rg-name> --assignee <your-email>

# You need at least "Azure Kubernetes Service Cluster User Role"
# Or "Azure Kubernetes Service Cluster Admin Role"
```

---

## 🧹 Cleanup

To remove the ServiceAccount from AKS:

```powershell
.\Remove-AKSServiceAccount.ps1
```

Then delete the service connection in Azure DevOps:
- Project Settings → Service connections → Delete

---

## 📚 Additional Scripts (Azure/AKS)

| Script | Purpose |
|--------|---------|
| `Get-AKSCredentials.ps1` | Configure kubectl for AKS |
| `Get-AKSServiceAccountToken.ps1` | Extract connection details |
| `Test-AKSConnection.ps1` | Test cluster connectivity |
| `Remove-AKSServiceAccount.ps1` | Cleanup resources |

---

## 💡 Common Azure CLI Commands

```powershell
# List AKS clusters
az aks list --output table

# Get AKS cluster details
az aks show --name <cluster-name> --resource-group <rg-name>

# List resource groups
az group list --output table

# Get current subscription
az account show

# Switch subscription
az account set --subscription <subscription-id>
```

---

## ✅ Success Checklist

- ✓ Azure CLI installed and logged in
- ✓ kubectl installed
- ✓ Connected to AKS cluster
- ✓ ServiceAccount created
- ✓ Token extracted
- ✓ Service connection created in Azure DevOps
- ✓ Service connection verified
- ✓ Ready to use in pipelines!

---

## 📞 Need Help?

- Azure CLI Documentation: https://docs.microsoft.com/cli/azure/
- AKS Documentation: https://docs.microsoft.com/azure/aks/
- Azure DevOps K8s Connection: https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints

