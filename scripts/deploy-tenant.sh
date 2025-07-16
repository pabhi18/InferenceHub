#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: ./deploy-tenant.sh <tenant-name>"
  echo "Example: ./deploy-tenant.sh model-1"
  exit 1
fi

TENANT="$1"
NAMESPACE="$TENANT"
VALUES_FILE="values/tenants/$TENANT.yaml"
RELEASE_NAME="$TENANT-tgi-platform"

if [ ! -f "$VALUES_FILE" ]; then
  echo "❌ Values file not found: $VALUES_FILE"
  exit 1
fi

echo "Deploying tenant: $TENANT"
helm upgrade --install "$RELEASE_NAME" ./helm/tgi-platform \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --values "$VALUES_FILE"

echo "Deployment complete for tenant: $TENANT"
