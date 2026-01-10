#!/bin/bash
set -e
echo "Setting up MinIO in the cluster..."

if [ "$#" -ne 2 ]; then
  echo "Usage: ./minio-setup.sh <MINIO_ROOT_USER> <MINIO_ROOT_PASSWORD>"
  echo "Example: ./minio-setup.sh minioadmin minioadmin123"
  exit 1
fi

MINIO_ROOT_USER="$1"
MINIO_ROOT_PASSWORD="$2"

helm repo add minio https://charts.min.io/
helm repo update

kubectl create namespace minio --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic minio-secret \
  --namespace minio \
  --from-literal=rootUser="${MINIO_ROOT_USER}" \
  --from-literal=rootPassword="${MINIO_ROOT_PASSWORD}" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install minio minio/minio \
  --namespace minio \
  --values values/minio-values.yaml 

echo "Applying virtual service for minio and minio-console..."
kubectl apply -f "istio/virtualservices/minio-console.yaml"
kubectl apply -f "istio/virtualservices/minio.yaml"

echo "MinIO setup complete."

