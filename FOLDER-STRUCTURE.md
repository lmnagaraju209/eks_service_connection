# 📂 Folder Structure

The scripts have been reorganized into platform-specific folders for better organization.

## ✅ New Structure

```
eks_service_connection/
│
├── 🔵 aks_scripts/                  # Azure AKS Scripts
│   ├── Get-AKSCredentials.ps1      # Configure kubectl for AKS
│   ├── Get-AKSServiceAccountToken.ps1
│   ├── Test-AKSConnection.ps1
│   ├── Remove-AKSServiceAccount.ps1
│   ├── Create-AKSServiceAccount.yaml
│   ├── .gitignore
│   └── README.md
│
├── 🟠 eks_scripts/                  # AWS EKS Scripts
│   ├── Get-EKSCredentials.ps1      # Configure kubectl for EKS
│   ├── Get-EKSServiceAccountToken.ps1
│   ├── Test-EKSConnection.ps1
│   ├── Remove-EKSServiceAccount.ps1
│   ├── Create-EKSServiceAccount.yaml
│   ├── .gitignore
│   └── README.md
│
├── 📁 examples/                     # Example pipelines
│   ├── eks-deployment-pipeline.yml
│   └── secure-deployment.yaml
│
└── 📚 Documentation:
    ├── README.md                    # Main documentation
    ├── WHICH-PLATFORM.md            # Platform selection guide
    ├── AZURE-AKS-QUICK-START.md    # Azure AKS quick start
    └── QUICK-START.md               # AWS EKS quick start
```

---

## 🎯 How to Use

### For Azure AKS:

```powershell
# Navigate to AKS scripts folder
cd D:\rathan_reddy\Mosaik\eks_service_connection\aks_scripts

# Run scripts
.\Get-AKSCredentials.ps1 -ClusterName "cluster" -ResourceGroup "rg"
.\Get-AKSServiceAccountToken.ps1
```

### For AWS EKS:

```powershell
# Navigate to EKS scripts folder
cd D:\rathan_reddy\Mosaik\eks_service_connection\eks_scripts

# Run scripts
.\Get-EKSCredentials.ps1 -ClusterName "cluster" -Region "us-east-1"
.\Get-EKSServiceAccountToken.ps1
```

---

## 📝 Key Changes

| Old Location | New Location |
|-------------|--------------|
| `scripts/Get-AKSCredentials.ps1` | `aks_scripts/Get-AKSCredentials.ps1` |
| `scripts/Get-EKSCredentials.ps1` | `eks_scripts/Get-EKSCredentials.ps1` |
| `scripts/Create-AKSServiceAccount.yaml` | `aks_scripts/Create-AKSServiceAccount.yaml` |
| `scripts/Create-EKSServiceAccount.yaml` | `eks_scripts/Create-EKSServiceAccount.yaml` |

---

## ✅ Benefits of New Structure

1. **Clearer Organization** - AKS and EKS scripts are separated
2. **Platform-Specific README** - Each folder has its own detailed documentation
3. **Easier Navigation** - No confusion about which scripts to use
4. **Protected Credentials** - Each folder has its own .gitignore
5. **Scalable** - Easy to add more platforms in the future

---

## 🚀 Quick Reference

### Azure AKS Cluster: `AZAMERES01KUB14031NP01`

```powershell
cd D:\rathan_reddy\Mosaik\eks_service_connection\aks_scripts
az login
.\Get-AKSCredentials.ps1 -ClusterName "AZAMERES01KUB14031NP01" -ResourceGroup "your-rg"
.\Get-AKSServiceAccountToken.ps1
```

### AWS EKS Cluster:

```powershell
cd D:\rathan_reddy\Mosaik\eks_service_connection\eks_scripts
.\Get-EKSCredentials.ps1 -ClusterName "your-cluster" -Region "us-east-1"
.\Get-EKSServiceAccountToken.ps1
```

---

## 📖 Documentation

- **Start Here:** [WHICH-PLATFORM.md](WHICH-PLATFORM.md)
- **Azure AKS:** [AZURE-AKS-QUICK-START.md](AZURE-AKS-QUICK-START.md)
- **AWS EKS:** [QUICK-START.md](QUICK-START.md)
- **AKS Scripts:** [aks_scripts/README.md](aks_scripts/README.md)
- **EKS Scripts:** [eks_scripts/README.md](eks_scripts/README.md)

