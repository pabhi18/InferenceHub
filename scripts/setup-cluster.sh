#!/bin/bash

set -e

echo "Setting up namespaces..."
kubectl apply -f infrastructure/namespaces/model-1-namespace.yaml
kubectl apply -f infrastructure/namespaces/model-2-namespace.yaml
kubectl apply -f infrastructure/namespaces/model-3-namespace.yaml
kubectl apply -f infrastructure/namespaces/monitoring-namespace.yaml

echo "Setting up storage classes..."
kubectl apply -f infrastructure/storage-classes/storageclass.yaml

echo "Setting up NGINX Ingress Controller..."

if kubectl get ns ingress-nginx >/dev/null 2>&1; then
  echo "Ingress-nginx namespace already exists. Skipping installation..."
else
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml
fi

echo "Cluster setup complete."
