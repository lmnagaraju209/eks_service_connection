#!/bin/bash
# Script to get EKS cluster credentials for Azure DevOps Service Connection

# Variables - Update these
EKS_CLUSTER_NAME="your-cluster-name"
AWS_REGION="us-east-1"

echo "========================================="
echo "Getting EKS Cluster Credentials"
echo "========================================="

# Update kubeconfig
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

# Get cluster endpoint
CLUSTER_ENDPOINT=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.endpoint' --output text)
echo "Cluster Endpoint: $CLUSTER_ENDPOINT"

# Get cluster CA certificate
aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.certificateAuthority.data' --output text > cluster-ca.crt

echo ""
echo "========================================="
echo "Cluster CA Certificate saved to: cluster-ca.crt"
echo "Cluster Endpoint: $CLUSTER_ENDPOINT"
echo "========================================="

