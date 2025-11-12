# Which Platform Should I Use?

This repository supports connecting Azure DevOps to both **Azure AKS** and **AWS EKS** clusters.

---

## 🎯 Choose Your Platform

### Option 1: Azure AKS (Azure Kubernetes Service)

**Use this if:**
- ✅ Your Kubernetes cluster is in Azure
- ✅ You have Azure CLI installed
- ✅ You have an Azure subscription
- ✅ Your infrastructure is primarily Azure-based

**Quick Start:**
```powershell
# Login to Azure
az login

# Get credentials
.\Get-AKSCredentials.ps1 -ClusterName "AZAMERES01KUB14031NP01" -ResourceGroup "your-resource-group"

# Get token
.\Get-AKSServiceAccountToken.ps1
```

📖 **Full Guide:** [AZURE-AKS-QUICK-START.md](AZURE-AKS-QUICK-START.md)

---

### Option 2: AWS EKS (Elastic Kubernetes Service)

**Use this if:**
- ✅ Your Kubernetes cluster is in AWS
- ✅ You have AWS CLI installed and configured
- ✅ You have an AWS account
- ✅ Your infrastructure is primarily AWS-based

**Quick Start:**
```powershell
# Get credentials
.\Get-EKSCredentials.ps1 -ClusterName "your-cluster-name" -Region "us-east-1"

# Get token
.\Get-EKSServiceAccountToken.ps1
```

📖 **Full Guide:** [QUICK-START.md](QUICK-START.md)

---

## 📋 Quick Comparison

| Feature | Azure AKS | AWS EKS |
|---------|-----------|---------|
| **CLI Tool** | Azure CLI (`az`) | AWS CLI (`aws`) |
| **Authentication** | `az login` | `aws configure` |
| **Get Credentials** | `az aks get-credentials` | `aws eks update-kubeconfig` |
| **Resource Group** | Required | Not required |
| **Region Parameter** | Automatic (from cluster) | Required |
| **PowerShell Scripts** | `Get-AKSCredentials.ps1` | `Get-EKSCredentials.ps1` |
| **Service Account Script** | `Get-AKSServiceAccountToken.ps1` | `Get-EKSServiceAccountToken.ps1` |

---

## 🔍 How to Identify Your Cluster Type

### Check Azure AKS:
```powershell
# List AKS clusters
az aks list --output table

# Check specific cluster
az aks show --name "cluster-name" --resource-group "rg-name"
```

### Check AWS EKS:
```powershell
# List EKS clusters
aws eks list-clusters --region us-east-1

# Check specific cluster
aws eks describe-cluster --name "cluster-name" --region us-east-1
```

---

## 📝 Example Cluster Names

### Azure AKS Pattern:
- Usually includes region/environment identifiers
- Example: `AZAMERES01KUB14031NP01`
- Naming often follows corporate patterns
- Located in an Azure Resource Group

### AWS EKS Pattern:
- Often named after environment/purpose
- Example: `prod-eks-cluster`, `dev-eks`
- May include region in name
- Associated with AWS region (e.g., `us-east-1`)

---

## 🎯 Your Cluster: `AZAMERES01KUB14031NP01`

Based on your cluster name pattern, this looks like an **Azure AKS** cluster.

**Recommended Path:**

1. **Use Azure AKS scripts**
2. **Follow this guide:** [AZURE-AKS-QUICK-START.md](AZURE-AKS-QUICK-START.md)

### Quick Commands:

```powershell
cd D:\rathan_reddy\Mosaik\eks_service_connection\aks_scripts

# Step 1: Login to Azure (if not already)
az login

# Step 2: Get AKS credentials
.\Get-AKSCredentials.ps1 -ClusterName "AZAMERES01KUB14031NP01" -ResourceGroup "your-resource-group-name"

# Step 3: Create ServiceAccount
.\Get-AKSServiceAccountToken.ps1
```

**Note:** You'll need to know your Azure Resource Group name. Find it with:
```powershell
az aks list --output table
```

---

## 🆘 Need Help Finding Your Resource Group?

```powershell
# List all resource groups
az group list --output table

# Search for resource groups containing "kub" or "aks"
az group list --query "[?contains(name,'kub') || contains(name,'aks')].name" --output table

# List all AKS clusters with their resource groups
az aks list --query "[].[name,resourceGroup,location]" --output table
```

---

## ✅ Prerequisites by Platform

### Azure AKS Prerequisites:
1. Azure CLI: https://aka.ms/installazurecliwindows
2. kubectl: `az aks install-cli` or https://kubernetes.io/docs/tasks/tools/
3. Azure account with access to the cluster
4. Know your: Cluster Name + Resource Group

### AWS EKS Prerequisites:
1. AWS CLI: https://aws.amazon.com/cli/
2. kubectl: https://kubernetes.io/docs/tasks/tools/
3. AWS account with access to the cluster
4. Know your: Cluster Name + Region

---

**Still unsure?** Run both checks:

```powershell
# Check if it's in Azure
az aks list --output table

# Check if it's in AWS
aws eks list-clusters --region us-east-1
```

The one that returns your cluster name is your platform!

