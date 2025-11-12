# Azure DevOps to Kubernetes Service Connection

Complete solution for creating and managing service connections from Azure DevOps to Kubernetes clusters on **Windows**.

## Supported Platforms:
- ✅ **Azure AKS** (Azure Kubernetes Service)
- ✅ **AWS EKS** (Elastic Kubernetes Service)

---

## 📁 Directory Structure

```
eks_service_connection/
├── aks_scripts/                         # Azure AKS PowerShell scripts
│   ├── Get-AKSCredentials.ps1          # Configure kubectl for AKS
│   ├── Get-AKSServiceAccountToken.ps1  # Extract AKS connection details
│   ├── Test-AKSConnection.ps1          # Test AKS connectivity
│   ├── Remove-AKSServiceAccount.ps1    # Cleanup AKS resources
│   ├── Create-AKSServiceAccount.yaml   # K8s ServiceAccount manifest
│   ├── .gitignore                      # Protects sensitive files
│   └── README.md                       # AKS scripts documentation
│
├── eks_scripts/                         # AWS EKS PowerShell scripts
│   ├── Get-EKSCredentials.ps1          # Configure kubectl for EKS
│   ├── Get-EKSServiceAccountToken.ps1  # Extract EKS connection details
│   ├── Test-EKSConnection.ps1          # Test EKS connectivity
│   ├── Remove-EKSServiceAccount.ps1    # Cleanup EKS resources
│   ├── Create-EKSServiceAccount.yaml   # K8s ServiceAccount manifest
│   ├── .gitignore                      # Protects sensitive files
│   └── README.md                       # EKS scripts documentation
│
├── examples/                            # Example files
│   ├── eks-deployment-pipeline.yml     # Example Azure Pipeline
│   └── secure-deployment.yaml          # Example K8s deployment (non-root)
│
├── AZURE-AKS-QUICK-START.md            # Azure AKS setup guide
├── QUICK-START.md                      # AWS EKS setup guide
├── WHICH-PLATFORM.md                   # Platform selection guide
└── README.md                           # This file
```

---

## 🚀 Quick Start

### For Azure AKS:

```powershell
cd D:\rathan_reddy\Mosaik\eks_service_connection\aks_scripts

# Step 1: Login to Azure
az login

# Step 2: Get AKS credentials
.\Get-AKSCredentials.ps1 -ClusterName "your-aks-cluster" -ResourceGroup "your-rg"

# Step 3: Create ServiceAccount and get token
.\Get-AKSServiceAccountToken.ps1
```

📖 **Full Guide:** See [AZURE-AKS-QUICK-START.md](AZURE-AKS-QUICK-START.md)

### For AWS EKS:

```powershell
cd D:\rathan_reddy\Mosaik\eks_service_connection\eks_scripts

# Step 1: Get EKS credentials
.\Get-EKSCredentials.ps1 -ClusterName "your-eks-cluster" -Region "us-east-1"

# Step 2: Create ServiceAccount and get token
.\Get-EKSServiceAccountToken.ps1
```

📖 **Full Guide:** See [QUICK-START.md](QUICK-START.md)

---

## 📚 Documentation

| Platform | Quick Start Guide | Prerequisites |
|----------|------------------|---------------|
| **Azure AKS** | [AZURE-AKS-QUICK-START.md](AZURE-AKS-QUICK-START.md) | Azure CLI, kubectl, Azure subscription |
| **AWS EKS** | [QUICK-START.md](QUICK-START.md) | AWS CLI, kubectl, AWS account |

---

## 🔐 Security Features

✅ **Non-Root Execution** - Pipelines enforce non-root user  
✅ **ServiceAccount Auth** - No admin kubeconfig needed  
✅ **RBAC Configured** - Proper permissions in K8s  
✅ **Token-Based** - Secure authentication  
✅ **Gitignore Setup** - Prevents credential leaks  

---

## 🔧 Available Scripts

### Azure AKS Scripts:

| Script | Purpose |
|--------|---------|
| `Get-AKSCredentials.ps1` | Configure kubectl for your AKS cluster |
| `Get-AKSServiceAccountToken.ps1` | Create ServiceAccount and extract token |
| `Test-AKSConnection.ps1` | Verify cluster connectivity |
| `Remove-AKSServiceAccount.ps1` | Clean up ServiceAccount resources |

### AWS EKS Scripts:

| Script | Purpose |
|--------|---------|
| `Get-EKSCredentials.ps1` | Configure kubectl for your EKS cluster |
| `Get-EKSServiceAccountToken.ps1` | Create ServiceAccount and extract token |
| `Test-EKSConnection.ps1` | Verify cluster connectivity |
| `Remove-EKSServiceAccount.ps1` | Clean up ServiceAccount resources |

---

## 📝 Example Usage

### Azure AKS Example:
```powershell
cd aks_scripts

# Get AKS credentials
.\Get-AKSCredentials.ps1 -ClusterName "prod-aks" -ResourceGroup "rg-prod"

# Create ServiceAccount
.\Get-AKSServiceAccountToken.ps1

# Test connection
.\Test-AKSConnection.ps1
```

### AWS EKS Example:
```powershell
cd eks_scripts

# Get EKS credentials
.\Get-EKSCredentials.ps1 -ClusterName "prod-eks" -Region "us-east-1"

# Create ServiceAccount
.\Get-EKSServiceAccountToken.ps1

# Test connection
.\Test-EKSConnection.ps1
```

---

## 🔍 Prerequisites

### For Azure AKS:
- ✅ Windows 10/11 with PowerShell
- ✅ [Azure CLI](https://aka.ms/installazurecliwindows) installed
- ✅ [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) installed
- ✅ Azure subscription with AKS access
- ✅ Admin access to Azure DevOps project

### For AWS EKS:
- ✅ Windows 10/11 with PowerShell
- ✅ [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- ✅ [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) installed
- ✅ AWS account with EKS access
- ✅ Admin access to Azure DevOps project

---

## ⚠️ Security Notes

**Sensitive Files Created:**
- `cluster-endpoint.txt`
- `cluster-ca-cert-base64.txt`
- `service-account-token.txt`

**⚠️ These files contain credentials. Delete them after use!**

```powershell
# After creating service connection:
Remove-Item cluster-*.txt, service-account-token.txt
```

---

## 🎯 What You Get

✓ Automated ServiceAccount creation in K8s  
✓ Secure token extraction  
✓ Azure DevOps service connection ready to use  
✓ Example pipeline with security checks  
✓ Example Kubernetes deployment (non-root)  
✓ Complete PowerShell automation for Windows  
✓ Support for both Azure AKS and AWS EKS  

---

## 🔄 Workflow

```
For Azure AKS:
1. Login to Azure CLI (az login)
2. Run Get-AKSCredentials.ps1
3. Run Get-AKSServiceAccountToken.ps1
4. Create Service Connection in Azure DevOps
5. Use in your pipelines

For AWS EKS:
1. Configure AWS CLI
2. Run Get-EKSCredentials.ps1
3. Run Get-EKSServiceAccountToken.ps1
4. Create Service Connection in Azure DevOps
5. Use in your pipelines
```

---

## 📞 Support

- **Azure AKS:** See `AZURE-AKS-QUICK-START.md`
- **AWS EKS:** See `QUICK-START.md`
- **Scripts:** See `scripts/README.md`
- **Examples:** See `examples/` folder

---

## ✅ Success Checklist

### Azure AKS:
- [ ] Azure CLI installed and logged in
- [ ] kubectl installed
- [ ] Connected to AKS cluster
- [ ] ServiceAccount created in AKS
- [ ] Connection details extracted
- [ ] Service connection created in Azure DevOps
- [ ] Service connection verified
- [ ] Example pipeline tested
- [ ] Sensitive files deleted locally

### AWS EKS:
- [ ] AWS CLI installed and configured
- [ ] kubectl installed
- [ ] Connected to EKS cluster
- [ ] ServiceAccount created in EKS
- [ ] Connection details extracted
- [ ] Service connection created in Azure DevOps
- [ ] Service connection verified
- [ ] Example pipeline tested
- [ ] Sensitive files deleted locally

---

**Ready to start?**

- For Azure AKS: Open `AZURE-AKS-QUICK-START.md`
- For AWS EKS: Open `QUICK-START.md`
