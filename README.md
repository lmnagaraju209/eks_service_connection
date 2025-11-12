# Azure DevOps to AWS EKS Service Connection

Complete solution for creating and managing service connections from Azure DevOps to AWS EKS clusters on **Windows**.

## 📁 Directory Structure

```
eks_service_connection/
├── scripts/                         # PowerShell scripts
│   ├── Get-EKSCredentials.ps1      # Configure kubectl for EKS
│   ├── Get-EKSServiceAccountToken.ps1  # Extract connection details
│   ├── Test-EKSConnection.ps1      # Test cluster connectivity
│   ├── Remove-EKSServiceAccount.ps1    # Cleanup resources
│   ├── Create-EKSServiceAccount.yaml   # K8s ServiceAccount manifest
│   └── README.md                   # Scripts documentation
├── examples/                        # Example files
│   ├── eks-deployment-pipeline.yml # Example Azure Pipeline
│   └── secure-deployment.yaml      # Example K8s deployment (non-root)
├── QUICK-START.md                  # Fast setup guide
├── FULL-GUIDE.md                   # Comprehensive documentation
└── README.md                       # This file
```

## 🚀 Quick Start

### 1. Prerequisites

- ✅ Windows 10/11 with PowerShell
- ✅ [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- ✅ [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) installed
- ✅ Access to AWS EKS cluster
- ✅ Admin access to Azure DevOps project

### 2. Run the Setup

```powershell
# Navigate to scripts folder
cd D:\rathan_reddy\Mosaik\eks_service_connection\scripts

# Step 1: Configure kubectl for EKS
.\Get-EKSCredentials.ps1 -ClusterName "your-cluster-name" -Region "us-east-1"

# Step 2: Create ServiceAccount and get connection details
.\Get-EKSServiceAccountToken.ps1
```

### 3. Create Service Connection

1. Go to [Azure DevOps Service Connections](https://dev.azure.com/MetLife-Global/Elastic-Cloud/_settings/adminservices)
2. Click "New service connection" → "Kubernetes"
3. Select "Service Account"
4. Copy values from generated text files:
   - **Server URL**: `cluster-endpoint.txt`
   - **Secret**: `service-account-token.txt`
5. Name it: `EKS-Mosaik-Production`
6. Click "Verify and save"

### 4. Use in Pipeline

```yaml
parameters:
- name: service_connection
  default: 'EKS-Mosaik-Production'

steps:
  - task: Kubernetes@1
    inputs:
      kubernetesServiceEndpoint: '${{parameters.service_connection}}'
      command: 'apply'
      arguments: '-f deployment.yaml'
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[QUICK-START.md](QUICK-START.md)** | 5-minute setup guide |
| **[scripts/README.md](scripts/README.md)** | PowerShell scripts documentation |
| **[examples/](examples/)** | Example pipelines and deployments |

## 🔐 Security Features

✅ **Non-Root Execution** - Pipelines enforce non-root user  
✅ **ServiceAccount Auth** - No admin kubeconfig needed  
✅ **RBAC Configured** - Proper permissions in EKS  
✅ **Token-Based** - Secure authentication  
✅ **Gitignore Setup** - Prevents credential leaks  

## 🔧 Available Scripts

| Script | Purpose |
|--------|---------|
| `Get-EKSCredentials.ps1` | Configure kubectl for your EKS cluster |
| `Get-EKSServiceAccountToken.ps1` | Create ServiceAccount and extract token |
| `Test-EKSConnection.ps1` | Verify cluster connectivity |
| `Remove-EKSServiceAccount.ps1` | Clean up ServiceAccount resources |

## 📝 Example Usage

### Basic Setup
```powershell
cd scripts
.\Get-EKSCredentials.ps1 -ClusterName "prod-eks" -Region "us-east-1"
.\Get-EKSServiceAccountToken.ps1
```

### Test Connection
```powershell
.\Test-EKSConnection.ps1
```

### Cleanup
```powershell
.\Remove-EKSServiceAccount.ps1
```

## 🔍 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| AWS CLI not found | Install from [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| kubectl not found | Install from [kubernetes.io](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) |
| Cannot connect to cluster | Run `aws sts get-caller-identity` to verify AWS creds |
| Secret not found | Wait a few seconds and try again (K8s 1.24+) |
| Unauthorized | Check IAM permissions and aws-auth ConfigMap |

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

## 🎯 What You Get

✓ Automated ServiceAccount creation in EKS  
✓ Secure token extraction  
✓ Azure DevOps service connection ready to use  
✓ Example pipeline with security checks  
✓ Example Kubernetes deployment (non-root)  
✓ Complete PowerShell automation  

## 🔄 Workflow

```
1. Run Get-EKSCredentials.ps1
   ↓
2. Run Get-EKSServiceAccountToken.ps1
   ↓
3. Create Service Connection in Azure DevOps
   ↓
4. Use in your pipelines
   ↓
5. Deploy securely to EKS (non-root)
```

## 📞 Support

- See `QUICK-START.md` for step-by-step guide
- See `scripts/README.md` for detailed script documentation
- See `examples/` for working pipeline examples

## ✅ Success Checklist

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

**Ready to start?** Open `QUICK-START.md` and follow the 5-minute guide!
