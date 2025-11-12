# EKS Service Connection Scripts (Windows/PowerShell)

This folder contains PowerShell scripts to create and manage service connections from Azure DevOps to AWS EKS.

## 📁 Files

| File | Description |
|------|-------------|
| `Create-EKSServiceAccount.yaml` | Kubernetes manifest for ServiceAccount and RBAC |
| `Get-EKSCredentials.ps1` | Configure kubectl for EKS cluster |
| `Get-EKSServiceAccountToken.ps1` | Extract connection details for Azure DevOps |
| `Test-EKSConnection.ps1` | Test EKS cluster connectivity |
| `Remove-EKSServiceAccount.ps1` | Clean up ServiceAccount resources |

## 🚀 Usage Order

### Step 1: Configure kubectl for EKS

```powershell
.\Get-EKSCredentials.ps1 -ClusterName "my-cluster" -Region "us-east-1"
```

**Parameters:**
- `-ClusterName` (required): Name of your EKS cluster
- `-Region` (required): AWS region where cluster is located

**What it does:**
- Updates kubeconfig
- Verifies connection
- Displays cluster information

### Step 2: Create ServiceAccount and Extract Token

```powershell
.\Get-EKSServiceAccountToken.ps1
```

**Optional Parameters:**
- `-Namespace`: Kubernetes namespace (default: "default")
- `-ServiceAccountName`: Name for ServiceAccount (default: "azdo-service-account")
- `-SecretName`: Name for secret (default: "azdo-service-account-token")

**What it does:**
- Creates ServiceAccount in EKS
- Creates ClusterRoleBinding with cluster-admin permissions
- Extracts and decodes token
- Saves connection details to files

**Output Files:**
- `cluster-endpoint.txt`
- `cluster-ca-cert-base64.txt`
- `service-account-token.txt`

### Step 3: Test Connection (Optional)

```powershell
.\Test-EKSConnection.ps1
```

**What it does:**
- Tests cluster connectivity
- Lists nodes
- Checks namespaces
- Verifies ServiceAccount exists

### Step 4: Cleanup (When needed)

```powershell
.\Remove-EKSServiceAccount.ps1
```

**Optional Parameters:**
- `-Namespace`: Namespace where ServiceAccount exists (default: "default")
- `-Force`: Skip confirmation prompt

**What it does:**
- Removes ServiceAccount
- Removes ClusterRoleBinding
- Removes Secret

---

## 📋 Prerequisites

### Required Tools:

1. **PowerShell** (included with Windows)
2. **AWS CLI**
   - Download: https://aws.amazon.com/cli/
   - Verify: `aws --version`
   - Configure: `aws configure`

3. **kubectl**
   - Download: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
   - Verify: `kubectl version --client`

### Required Access:

- AWS credentials configured (IAM user or role)
- EKS cluster access
- Kubernetes cluster-admin permissions
- Azure DevOps project admin access

---

## 💡 Examples

### Example 1: Basic Setup

```powershell
# Step 1: Connect to EKS
.\Get-EKSCredentials.ps1 -ClusterName "prod-cluster" -Region "us-east-1"

# Step 2: Create ServiceAccount and get token
.\Get-EKSServiceAccountToken.ps1

# Step 3: View the token
Get-Content service-account-token.txt
```

### Example 2: Using Custom Namespace

```powershell
# Create ServiceAccount in 'production' namespace
.\Get-EKSServiceAccountToken.ps1 -Namespace "production"
```

### Example 3: Test Before Creating

```powershell
# First, verify you can connect
.\Test-EKSConnection.ps1

# If successful, proceed with ServiceAccount creation
.\Get-EKSServiceAccountToken.ps1
```

### Example 4: Cleanup and Recreate

```powershell
# Remove existing ServiceAccount
.\Remove-EKSServiceAccount.ps1 -Force

# Create new one
.\Get-EKSServiceAccountToken.ps1
```

---

## 🔍 Troubleshooting

### Error: "AWS CLI not found"

**Solution:**
```powershell
# Install AWS CLI from:
# https://aws.amazon.com/cli/

# After install, verify:
aws --version
```

### Error: "kubectl not found"

**Solution:**
```powershell
# Install kubectl from:
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

# Add to PATH or run from kubectl directory
```

### Error: "Failed to update kubeconfig"

**Solution:**
```powershell
# Verify AWS credentials
aws sts get-caller-identity

# Check if cluster exists
aws eks list-clusters --region us-east-1

# Verify IAM permissions for EKS
```

### Error: "Not connected to Kubernetes cluster"

**Solution:**
```powershell
# Run Get-EKSCredentials.ps1 first
.\Get-EKSCredentials.ps1 -ClusterName "your-cluster" -Region "your-region"

# Verify connection
kubectl cluster-info
```

### Error: "Secret not found"

**Solution:**
```powershell
# Check if ServiceAccount exists
kubectl get sa azdo-service-account -n default

# Re-apply the manifest
kubectl apply -f Create-EKSServiceAccount.yaml

# Wait a few seconds for secret to be created
Start-Sleep -Seconds 5

# Try again
.\Get-EKSServiceAccountToken.ps1
```

### Error: "Unauthorized" when verifying connection

**Solution:**
- Check IAM permissions on AWS
- Verify aws-auth ConfigMap in EKS
- Ensure your IAM user/role has EKS access

---

## 🔒 Security Notes

### ⚠️ Important Security Considerations:

1. **Sensitive Files:**
   - `cluster-endpoint.txt`
   - `cluster-ca-cert-base64.txt`
   - `service-account-token.txt`
   
   These contain sensitive information. **Never commit to source control!**

2. **Token Security:**
   - Tokens grant full cluster access (cluster-admin)
   - Store securely in Azure DevOps only
   - Rotate regularly
   - Delete local files after creating service connection

3. **Least Privilege:**
   - Default uses cluster-admin (full access)
   - For production, use more restrictive RBAC
   - See FULL-GUIDE.md for least-privilege examples

4. **Cleanup:**
   ```powershell
   # After creating service connection, delete local files
   Remove-Item cluster-endpoint.txt, cluster-ca-cert-base64.txt, service-account-token.txt
   ```

---

## 📝 Quick Reference

### Copy Values to Clipboard

```powershell
# Copy endpoint
Get-Content cluster-endpoint.txt | Set-Clipboard

# Copy token
Get-Content service-account-token.txt | Set-Clipboard
```

### View All Connection Details

```powershell
Write-Host "Endpoint:" (Get-Content cluster-endpoint.txt)
Write-Host "Token:" (Get-Content service-account-token.txt)
```

### Check ServiceAccount Status

```powershell
kubectl get sa azdo-service-account -n default
kubectl get secret azdo-service-account-token -n default
kubectl get clusterrolebinding azdo-cluster-admin
```

---

## 🎯 Next Steps

After running these scripts:

1. Go to Azure DevOps Service Connections
2. Create new Kubernetes service connection
3. Use values from generated text files
4. Test in a pipeline
5. Delete local text files for security

See `QUICK-START.md` for detailed walkthrough!
