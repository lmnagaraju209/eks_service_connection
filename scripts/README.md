# EKS Service Connection Setup Scripts

This folder contains scripts to help you create a service connection from Azure DevOps to AWS EKS.

## 📁 Files

| File | Description |
|------|-------------|
| `create-eks-serviceaccount.yaml` | Kubernetes manifest to create ServiceAccount and RBAC |
| `get-eks-service-account-token.sh` | Bash script to extract connection details (Linux/Mac) |
| `Get-EKSServiceAccountToken.ps1` | PowerShell script to extract connection details (Windows) |
| `get-eks-credentials.sh` | Helper script to get EKS credentials |

## 🚀 Usage

### For Windows (PowerShell):

```powershell
# Navigate to scripts folder
cd scripts

# Run PowerShell script
.\Get-EKSServiceAccountToken.ps1
```

### For Linux/Mac (Bash):

```bash
# Navigate to scripts folder
cd scripts

# Make scripts executable
chmod +x *.sh

# Run bash script
./get-eks-service-account-token.sh
```

## 📋 Prerequisites

Before running these scripts:

1. **AWS CLI** installed and configured
2. **kubectl** installed and configured
3. **EKS cluster** accessible
4. Update kubeconfig:
   ```bash
   aws eks update-kubeconfig --name <your-cluster-name> --region <region>
   ```
5. Verify connection:
   ```bash
   kubectl cluster-info
   ```

## 📤 Output

The scripts will generate three files:

- `cluster-endpoint.txt` - The Kubernetes API server URL
- `cluster-ca-cert-base64.txt` - The cluster CA certificate (base64 encoded)
- `service-account-token.txt` - The ServiceAccount authentication token

**Use these values** when creating the service connection in Azure DevOps.

## 🔐 What Gets Created

The scripts create:

1. **ServiceAccount** named `azdo-service-account` in the `default` namespace
2. **ClusterRoleBinding** giving the ServiceAccount `cluster-admin` privileges
3. **Secret** containing the ServiceAccount token (for K8s 1.24+)

## ⚠️ Security Notes

- The `cluster-admin` role grants full access to the cluster
- For production, consider using more restrictive RBAC roles
- See the full documentation for least-privilege examples
- Rotate tokens regularly
- Don't commit token files to source control

## 🔧 Troubleshooting

### Error: "Unable to connect to the server"
```bash
# Verify kubectl is configured
kubectl cluster-info

# Update kubeconfig
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

### Error: "ServiceAccount not found"
```bash
# Check if ServiceAccount was created
kubectl get sa azdo-service-account -n default

# If not, apply the manifest
kubectl apply -f create-eks-serviceaccount.yaml
```

### Error: "Secret not found"
```bash
# Check if secret exists
kubectl get secret azdo-service-account-token -n default

# For Kubernetes 1.24+, the secret is created automatically
# For older versions, you may need to manually create it
```

## 📚 Full Documentation

See the complete guide: `docs/AZURE-DEVOPS-EKS-SERVICE-CONNECTION-GUIDE.md`

## 🎯 Quick Start

See: `QUICK-START-EKS-CONNECTION.md` in the root folder

