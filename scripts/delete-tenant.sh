#!/bin/bash
set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: ./delete-tenant.sh <tenant-name> [model-name]"
  echo "Example: ./delete-tenant.sh model-1 llama-7b"
  exit 1
fi

TENANT="$1"
MODEL_NAME="${2:-$TENANT}"
NAMESPACE="$TENANT"
RELEASE_NAME="$TENANT-vllm-platform"

echo "Deleting: $TENANT"
echo "Model: $MODEL_NAME"

echo "Deleting vLLM deployment..."
helm uninstall "$RELEASE_NAME" --namespace "$NAMESPACE" 2>/dev/null || echo "Helm release not found"

echo "Deleting namespace..."
kubectl delete namespace "$NAMESPACE" --ignore-not-found=true


echo "Model '$MODEL_NAME' removed from Open WebUI"