# AWS EKS Scripts (Windows/PowerShell)

PowerShell scripts to create and manage service connections from Azure DevOps to **AWS Elastic Kubernetes Service (EKS)**.

## 📁 Files

| File | Description |
|------|-------------|
| `Get-EKSCredentials.ps1` | Configure kubectl for your EKS cluster |
| `Get-EKSServiceAccountToken.ps1` | Create ServiceAccount and extract connection details |
| `Test-EKSConnection.ps1` | Test EKS cluster connectivity |
| `Remove-EKSServiceAccount.ps1` | Clean up ServiceAccount resources |
| `Create-EKSServiceAccount.yaml` | Kubernetes manifest for ServiceAccount and RBAC |
| `.gitignore` | Protects sensitive credential files |

## 🚀 Quick Start

### Step 1: Configure AWS CLI

```powershell
# Configure AWS CLI credentials
aws configure

# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)

# Verify configuration
aws sts get-caller-identity
```

### Step 2: Get EKS Credentials

```powershell
# Find your cluster
aws eks list-clusters --region us-east-1

# Get credentials
.\Get-EKSCredentials.ps1 -ClusterName "your-cluster-name" -Region "us-east-1"
```

### Step 3: Create ServiceAccount and Extract Token

```powershell
.\Get-EKSServiceAccountToken.ps1
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
5. Service connection name: `EKS-Mosaik-Production`
6. Click: "Verify and save"

### Step 5: Test (Optional)

```powershell
.\Test-EKSConnection.ps1
```

## 📋 Prerequisites

- Windows 10/11 with PowerShell
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) installed
- AWS account with EKS access
- Admin access to Azure DevOps project

## 🔧 Script Parameters

### Get-EKSCredentials.ps1

```powershell
.\Get-EKSCredentials.ps1 -ClusterName <name> -Region <region>
```

**Parameters:**
- `-ClusterName` (required): EKS cluster name
- `-Region` (required): AWS region (e.g., us-east-1, eu-west-1)

### Get-EKSServiceAccountToken.ps1

```powershell
.\Get-EKSServiceAccountToken.ps1 [-Namespace <namespace>] [-ServiceAccountName <name>] [-SecretName <name>]
```

**Parameters:**
- `-Namespace` (optional, default: "default"): Kubernetes namespace
- `-ServiceAccountName` (optional, default: "azdo-service-account"): ServiceAccount name
- `-SecretName` (optional, default: "azdo-service-account-token"): Secret name

### Remove-EKSServiceAccount.ps1

```powershell
.\Remove-EKSServiceAccount.ps1 [-Namespace <namespace>] [-Force]
```

**Parameters:**
- `-Namespace` (optional, default: "default"): Kubernetes namespace
- `-Force` (optional): Skip confirmation prompt

## 🔍 Troubleshooting

### Error: "AWS CLI not found"

```powershell
# Install AWS CLI
# Download from: https://aws.amazon.com/cli/

# Verify installation
aws --version
```

### Error: "AWS credentials not configured"

```powershell
# Configure AWS credentials
aws configure

# Or verify existing configuration
aws sts get-caller-identity
aws configure list
```

### Error: "kubectl not found"

```powershell
# Install kubectl
# Download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

# Verify installation
kubectl version --client
```

### Error: "Cannot connect to cluster"

```powershell
# List EKS clusters in region
aws eks list-clusters --region us-east-1

# Update kubeconfig
aws eks update-kubeconfig --name <cluster-name> --region <region>

# Verify connection
kubectl cluster-info
```

### Error: "Unauthorized" or "Access Denied"

```powershell
# Check IAM permissions
aws sts get-caller-identity

# Verify aws-auth ConfigMap in EKS
kubectl get configmap aws-auth -n kube-system -o yaml

# You need IAM permissions for:
# - eks:DescribeCluster
# - eks:ListClusters
# And your IAM user/role must be in the aws-auth ConfigMap
```

## 💡 Common AWS CLI Commands

```powershell
# List EKS clusters
aws eks list-clusters --region us-east-1

# Get cluster details
aws eks describe-cluster --name <cluster-name> --region <region>

# List all regions
aws ec2 describe-regions --output table

# Get current IAM identity
aws sts get-caller-identity

# Update kubeconfig
aws eks update-kubeconfig --name <cluster-name> --region <region>
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

# 1. Configure AWS CLI
aws configure
aws sts get-caller-identity

# 2. Navigate to scripts
cd D:\rathan_reddy\Mosaik\eks_service_connection\eks_scripts

# 3. Get EKS credentials
.\Get-EKSCredentials.ps1 -ClusterName "prod-eks-cluster" -Region "us-east-1"

# 4. Create ServiceAccount and get token
.\Get-EKSServiceAccountToken.ps1

# 5. View the files
notepad cluster-endpoint.txt
notepad service-account-token.txt

# 6. Test connection
.\Test-EKSConnection.ps1

# 7. After creating service connection in Azure DevOps, cleanup
Remove-Item cluster-*.txt, service-account-token.txt
```

## 🧹 Cleanup

To remove the ServiceAccount from EKS:

```powershell
.\Remove-EKSServiceAccount.ps1
```

Then delete the service connection in Azure DevOps:
- Project Settings → Service connections → Delete

## 📚 Additional Resources

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Azure DevOps Kubernetes Connection](https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints)
- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

## ✅ Success Checklist

- [ ] AWS CLI installed
- [ ] kubectl installed
- [ ] AWS credentials configured
- [ ] IAM permissions verified
- [ ] EKS cluster name and region known
- [ ] EKS credentials retrieved
- [ ] ServiceAccount created
- [ ] Token files generated
- [ ] Service connection created in Azure DevOps
- [ ] Service connection verified and working
- [ ] Sensitive files deleted locally

---

**Need help?** See the parent folder's [QUICK-START.md](../QUICK-START.md) for a complete walkthrough.

