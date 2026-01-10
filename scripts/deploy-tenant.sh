#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: ./deploy-tenant.sh <tenant-name>"
  echo "Example: ./deploy-tenant.sh model-1"
  exit 1
fi

TENANT="$1"
MODEL_NAME="$TENANT"
NAMESPACE="$TENANT"
VALUES_FILE="values/tenants/$TENANT.yaml"
SECRET_FILE="values/tenants/minio-secrets-value.yaml"
RELEASE_NAME="$TENANT-vllm-platform"
MODEL_URL="http://${TENANT}-vllm-platform.${TENANT}.svc.cluster.local:8000/v1"

if [ ! -f "$VALUES_FILE" ]; then
  echo "Values file not found: $VALUES_FILE"
  exit 1
fi

echo "Deploying tenant: $TENANT"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install "$RELEASE_NAME" ./helm/vllm-platform \
  --namespace "$NAMESPACE" \
  --create-namespace \
  -f "$VALUES_FILE" \
  -f "$SECRET_FILE" \

echo "Updating Open WebUI values..."

sed -i.bak \
  -e "/openaiBaseApiUrls:/,/openaiApiKeys:/c\\
openaiBaseApiUrls:\\
  - \"$MODEL_URL\"
" \
  -e "/- name: OPENAI_API_BASE_URL/{n;c\\
    value: \"$MODEL_URL\"
}" \
  values/open-webui-values.yaml

helm upgrade --install open-webui open-webui/open-webui \
  --namespace open-webui \
  --values values/open-webui-values.yaml

echo "COMPLETE!"
echo "Model '$MODEL_NAME' is now available in Open WebUI"
