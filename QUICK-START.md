# Quick Start: Azure DevOps to EKS Service Connection (Windows)

## 🚀 Fast Setup (5 Minutes)

### Prerequisites
- AWS CLI installed and configured
- kubectl installed
- PowerShell (comes with Windows)
- Access to EKS cluster
- Admin access to Azure DevOps project

---

## Step-by-Step Guide

### 1️⃣ Configure kubectl for EKS

Open PowerShell and navigate to the scripts folder:

```powershell
cd D:\rathan_reddy\Mosaik\eks_service_connection\scripts

# Replace with your actual cluster name and region
.\Get-EKSCredentials.ps1 -ClusterName "your-cluster-name" -Region "us-east-1"
```

**✓ This will:**
- Update your kubeconfig
- Verify connection to EKS
- Display cluster information

### 2️⃣ Create ServiceAccount and Get Token

```powershell
.\Get-EKSServiceAccountToken.ps1
```

**✓ This will:**
- Create ServiceAccount in EKS cluster
- Extract connection details
- Save to text files:
  - `cluster-endpoint.txt`
  - `cluster-ca-cert-base64.txt`
  - `service-account-token.txt`

### 3️⃣ Create Service Connection in Azure DevOps

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
   | **Service connection name** | `EKS-Mosaik-Production` |

5. **Check:** "Grant access permission to all pipelines"

6. **Click:** "Verify and save"

### 4️⃣ Update Your Pipeline

Now you can use the service connection in your pipeline:

```yaml
parameters:
- name: service_connection
  type: string
  displayName: 'Service Connection'
  default: 'EKS-Mosaik-Production'

steps:
  - task: Kubernetes@1
    inputs:
      connectionType: 'Kubernetes Service Connection'
      kubernetesServiceEndpoint: '${{parameters.service_connection}}'
      command: 'apply'
      arguments: '-f deployment.yaml'
```

### 5️⃣ Test the Connection (Optional)

```powershell
.\Test-EKSConnection.ps1
```

---

## 📁 Files Created

In the `scripts` folder, you'll find:
- ✅ `cluster-endpoint.txt` - Server URL for Azure DevOps
- ✅ `cluster-ca-cert-base64.txt` - CA certificate (base64)
- ✅ `service-account-token.txt` - Authentication token

**⚠️ Important:** These files contain sensitive information. Don't commit them to source control!

---

## 🔍 Troubleshooting

### Issue: "AWS CLI not found"
```powershell
# Check if AWS CLI is installed
aws --version

# If not, download from:
# https://aws.amazon.com/cli/
```

### Issue: "kubectl not found"
```powershell
# Check if kubectl is installed
kubectl version --client

# If not, download from:
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

### Issue: "Cannot connect to cluster"
```powershell
# Verify AWS credentials
aws sts get-caller-identity

# Update kubeconfig again
aws eks update-kubeconfig --name <cluster-name> --region <region>

# Test connection
kubectl cluster-info
```

### Issue: "Secret not found"
This may happen on Kubernetes 1.24+. The secret should be created automatically. If not:
1. Verify ServiceAccount exists: `kubectl get sa azdo-service-account`
2. Re-apply the YAML: `kubectl apply -f Create-EKSServiceAccount.yaml`
3. Wait a few seconds and try again

---

## 🧹 Cleanup

To remove the ServiceAccount from EKS:

```powershell
.\Remove-EKSServiceAccount.ps1
```

Then delete the service connection in Azure DevOps:
- Project Settings → Service connections → Delete

---

## 📚 Additional Scripts

| Script | Purpose |
|--------|---------|
| `Get-EKSCredentials.ps1` | Configure kubectl for EKS |
| `Get-EKSServiceAccountToken.ps1` | Extract connection details |
| `Test-EKSConnection.ps1` | Test cluster connectivity |
| `Remove-EKSServiceAccount.ps1` | Cleanup resources |

---

## ✅ Success Checklist

- ✓ AWS CLI installed and configured
- ✓ kubectl installed
- ✓ Connected to EKS cluster
- ✓ ServiceAccount created
- ✓ Token extracted
- ✓ Service connection created in Azure DevOps
- ✓ Service connection verified
- ✓ Ready to use in pipelines!

---

## 📞 Need Help?

See the full documentation in `FULL-GUIDE.md` for:
- Detailed explanations
- Security best practices
- Advanced configurations
- Alternative methods
- Example pipelines

