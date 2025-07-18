#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "ERROR: GRAFANA_ADMIN_PASSWORD as an argument required"
  echo "Example: ./scripts/deploy-monitoring.sh your-password"
  exit 1
fi

GRAFANA_ADMIN_PASSWORD="$1"

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f helm/monitoring/values.yaml \
  --set grafana.adminPassword="${GRAFANA_ADMIN_PASSWORD}"

echo "Monitoring stack deployed successfully..."