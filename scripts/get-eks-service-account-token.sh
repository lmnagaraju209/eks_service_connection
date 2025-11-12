#!/bin/bash
# Script to get ServiceAccount token for Azure DevOps connection to EKS

echo "========================================="
echo "Creating ServiceAccount and Getting Token"
echo "========================================="

# Apply the ServiceAccount and RBAC
kubectl apply -f create-eks-serviceaccount.yaml

# Wait for token to be created
echo "Waiting for token secret to be created..."
sleep 5

# Get the token
TOKEN=$(kubectl get secret azdo-service-account-token -n default -o jsonpath='{.data.token}' | base64 --decode)

# Get the CA certificate
CA_CERT=$(kubectl get secret azdo-service-account-token -n default -o jsonpath='{.data.ca\.crt}')

# Get cluster endpoint
CLUSTER_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

echo ""
echo "========================================="
echo "EKS Cluster Connection Details"
echo "========================================="
echo ""
echo "Cluster Endpoint (Server URL):"
echo "$CLUSTER_ENDPOINT"
echo ""
echo "CA Certificate (base64):"
echo "$CA_CERT"
echo ""
echo "Service Account Token:"
echo "$TOKEN"
echo ""
echo "========================================="
echo "Save these values for Azure DevOps Service Connection"
echo "========================================="

# Optionally save to files
echo "$CLUSTER_ENDPOINT" > cluster-endpoint.txt
echo "$CA_CERT" > cluster-ca-cert-base64.txt
echo "$TOKEN" > service-account-token.txt

echo ""
echo "Values saved to:"
echo "  - cluster-endpoint.txt"
echo "  - cluster-ca-cert-base64.txt"
echo "  - service-account-token.txt"

