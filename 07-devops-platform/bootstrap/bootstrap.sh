#!/bin/bash

set -e

PROJECT_NAME="devops-platform"
REGION="eu-west-3"
CLUSTER_NAME="devops-cluster"

echo "Initialisation de Terraform..."
cd terraform
terraform init -input=false
terraform apply -auto-approve

echo "Récupération du kubeconfig..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo "Attente de l'adresse publique d'ArgoCD (LoadBalancer)..."
while true; do
  LB_HOST=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  if [[ -n "$LB_HOST" ]]; then
    break
  fi
  echo "En attente..."
  sleep 10
done

ARGO_URL="https://${LB_HOST}"
echo "ArgoCD est disponible à l'adresse : $ARGO_URL"
