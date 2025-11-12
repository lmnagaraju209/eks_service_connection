# Quick Start: Azure DevOps to EKS Service Connection

## 🚀 Fast Setup (5 Minutes)

### 1️⃣ Run the Setup Scripts

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Create ServiceAccount in EKS
kubectl apply -f scripts/create-eks-serviceaccount.yaml

# Get connection details
cd scripts
./get-eks-service-account-token.sh
```

**📝 Copy the output values:**
- Server URL
- CA Certificate
- Service Account Token

### 2️⃣ Create Service Connection in Azure DevOps

1. Go to: **Azure DevOps** → **Project Settings** → **Service connections**
2. Click: **New service connection** → **Kubernetes**
3. Choose: **Service Account**
4. Fill in:
   - **Server URL**: (from script output)
   - **Secret**: (Service Account Token from script)
   - **Name**: `EKS-Mosaik-Production`
5. Click: **Verify and save**

### 3️⃣ Update Your Pipeline

```yaml
parameters:
- name: service_connection
  type: string
  displayName: 'Service Connection'
  default: 'EKS-Mosaik-Production'  # ← Add this

steps:
  - task: Kubernetes@1
    inputs:
      connectionType: 'Kubernetes Service Connection'
      kubernetesServiceEndpoint: '${{parameters.service_connection}}'
      command: 'apply'
      arguments: '-f deployment.yaml'
```

### 4️⃣ Test It

Run the pipeline and check the logs!

---

## 📁 Files Created

- `scripts/create-eks-serviceaccount.yaml` - K8s ServiceAccount definition
- `scripts/get-eks-service-account-token.sh` - Script to extract credentials
- `docs/AZURE-DEVOPS-EKS-SERVICE-CONNECTION-GUIDE.md` - Full documentation
- `examples/eks-deployment-pipeline.yml` - Example pipeline

---

## 🔍 Troubleshooting

**Fields not editable?**
- Check that parameters have `default: ''` in the YAML

**Connection fails?**
- Verify: `kubectl cluster-info` works locally
- Check: ServiceAccount exists: `kubectl get sa azdo-service-account`
- Confirm: Token is valid: `kubectl get secret azdo-service-account-token`

**403 Forbidden?**
- Verify RBAC: `kubectl get clusterrolebinding azdo-cluster-admin`

---

## 📚 Full Documentation

See: `docs/AZURE-DEVOPS-EKS-SERVICE-CONNECTION-GUIDE.md`

---

## ✅ What You Get

✓ Non-root pipeline execution (security compliant)  
✓ EKS service connection configured  
✓ Ready-to-use example pipeline  
✓ ServiceAccount with proper RBAC  
✓ Complete documentation  

---

**Need help?** Check the full guide in the `docs/` folder!

