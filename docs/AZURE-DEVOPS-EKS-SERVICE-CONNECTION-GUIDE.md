# Azure DevOps to AWS EKS Service Connection Setup Guide

This guide explains how to create a service connection from Azure DevOps to an AWS EKS cluster.

## 📋 Prerequisites

- AWS CLI installed and configured
- kubectl installed and configured
- Access to AWS EKS cluster
- Admin access to Azure DevOps project
- EKS cluster name and AWS region

---

## 🔐 Method 1: Kubernetes Service Connection (Recommended)

### Step 1: Configure kubectl for EKS

```bash
# Update kubeconfig for your EKS cluster
aws eks update-kubeconfig --name <your-cluster-name> --region <aws-region>

# Verify connection
kubectl cluster-info
```

### Step 2: Create ServiceAccount in EKS

Run the following script to create a ServiceAccount for Azure DevOps:

```bash
cd scripts
chmod +x get-eks-service-account-token.sh
kubectl apply -f create-eks-serviceaccount.yaml
./get-eks-service-account-token.sh
```

This will output:
- **Server URL** (Cluster Endpoint)
- **CA Certificate** (base64 encoded)
- **Service Account Token**

**Save these values** - you'll need them in the next steps!

### Step 3: Create Service Connection in Azure DevOps

1. **Navigate to Service Connections:**
   - Go to Azure DevOps Project
   - Click **Project Settings** (gear icon, bottom left)
   - Under **Pipelines**, click **Service connections**
   - Click **New service connection**

2. **Select Kubernetes:**
   - Choose **Kubernetes** from the list
   - Click **Next**

3. **Choose Authentication Method:**
   - Select **Service Account**

4. **Fill in the Details:**
   
   | Field | Value |
   |-------|-------|
   | **Server URL** | Paste the Cluster Endpoint from Step 2 |
   | **Secret** | Paste the Service Account Token from Step 2 |
   | **Service connection name** | `EKS-Mosaik-Production` (or your preferred name) |
   | **Description** | `Connection to AWS EKS cluster for Mosaik APM` |
   | **Grant access permission to all pipelines** | ✅ Check this (or configure per-pipeline) |

5. **Click "Verify and save"**

---

## 🔐 Method 2: AWS Service Connection + kubectl (Alternative)

This method uses AWS credentials to authenticate with EKS.

### Step 1: Create AWS IAM User for Azure DevOps

```bash
# Create IAM user
aws iam create-user --user-name azdo-eks-user

# Create access key
aws iam create-access-key --user-name azdo-eks-user

# Save the AccessKeyId and SecretAccessKey
```

### Step 2: Grant EKS Permissions

```bash
# Attach EKS policy
aws iam attach-user-policy \
  --user-name azdo-eks-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Update aws-auth ConfigMap in EKS
kubectl edit configmap aws-auth -n kube-system
```

Add the IAM user to the ConfigMap:

```yaml
mapUsers: |
  - userarn: arn:aws:iam::<account-id>:user/azdo-eks-user
    username: azdo-eks-user
    groups:
      - system:masters
```

### Step 3: Create AWS Service Connection in Azure DevOps

1. **Navigate to Service Connections**
2. **New service connection** → **AWS**
3. **Fill in details:**
   - **Access Key ID**: From Step 1
   - **Secret Access Key**: From Step 1
   - **Service connection name**: `AWS-EKS-Connection`
4. **Verify and save**

---

## 📝 Using the Service Connection in Your Pipeline

Once created, use it in your pipeline:

```yaml
steps:
  - task: Kubernetes@1
    displayName: 'Deploy to EKS'
    inputs:
      connectionType: 'Kubernetes Service Connection'
      kubernetesServiceEndpoint: 'EKS-Mosaik-Production'
      command: 'apply'
      arguments: '-f deployment.yaml'
```

Or for AWS credentials approach:

```yaml
steps:
  - task: AWSCLI@1
    inputs:
      awsCredentials: 'AWS-EKS-Connection'
      regionName: 'us-east-1'
      awsCommand: 'eks'
      awsSubCommand: 'update-kubeconfig'
      awsArguments: '--name my-cluster'
  
  - script: kubectl apply -f deployment.yaml
    displayName: 'Deploy to EKS'
```

---

## 🔍 Troubleshooting

### Issue: "Unable to connect to the server"
- **Solution**: Verify the Server URL is correct and accessible from Azure DevOps agents

### Issue: "Unauthorized"
- **Solution**: Check that the ServiceAccount token is valid and has proper RBAC permissions

### Issue: "Certificate validation failed"
- **Solution**: Ensure CA certificate is correctly base64 encoded

### Issue: "Forbidden"
- **Solution**: Verify ClusterRoleBinding is applied correctly:
  ```bash
  kubectl get clusterrolebinding azdo-cluster-admin
  ```

---

## 🔒 Security Best Practices

1. **Use ServiceAccount tokens** instead of admin kubeconfig
2. **Apply least privilege** - Don't use cluster-admin unless necessary
3. **Rotate tokens regularly**
4. **Use namespace-specific RoleBindings** when possible:

```yaml
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

5. **Enable audit logging** on EKS cluster
6. **Use separate service connections** for different environments (dev/staging/prod)

---

## ✅ Verification

Test your connection:

```yaml
# test-connection.yml
trigger: none

pool:
  name: Auto-Scaling-Agents-Linux

steps:
  - task: Kubernetes@1
    displayName: 'Test EKS Connection'
    inputs:
      connectionType: 'Kubernetes Service Connection'
      kubernetesServiceEndpoint: 'EKS-Mosaik-Production'
      command: 'get'
      arguments: 'nodes'
```

---

## 📚 Additional Resources

- [Azure DevOps Kubernetes Service Connection](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#kubernetes)
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

---

## 🎯 Quick Command Reference

```bash
# Get cluster info
aws eks describe-cluster --name <cluster-name> --region <region>

# Update kubeconfig
aws eks update-kubeconfig --name <cluster-name> --region <region>

# List service accounts
kubectl get serviceaccounts -n default

# Get token
kubectl get secret <secret-name> -n default -o jsonpath='{.data.token}' | base64 --decode

# Test connection
kubectl cluster-info
kubectl get nodes
```

