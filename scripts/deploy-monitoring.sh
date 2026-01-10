#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "ERROR: GRAFANA_ADMIN_PASSWORD as an argument required"
  echo "Example: ./scripts/deploy-monitoring.sh your-password"
  exit 1
fi

GRAFANA_ADMIN_PASSWORD="$1"

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set grafana.adminPassword="${GRAFANA_ADMIN_PASSWORD}"

# echo "Deploying NVIDIA DCGM Exporter for GPU metrics..."
# helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
# helm repo update

# helm install dcgm-exporter gpu-helm-charts/dcgm-exporter -n monitoring

echo "Applying virtual service..."
kubectl apply -f "istio/virtualservices/grafana.yaml"

echo "Monitoring stack (Prometheus + Grafana + GPU metrics) deployed successfully..."