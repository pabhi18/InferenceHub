#!/bin/bash
set -e

echo "Setting up WebUI in the cluster..."

helm repo add open-webui https://open-webui.github.io/helm-charts
helm repo update

kubectl create namespace open-webui --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install open-webui open-webui/open-webui \
  --namespace open-webui \
  --values values/open-webui-values.yaml

echo "Applying virtual service for openwebui..."
kubectl apply -f "istio/virtualservices/openwebui.yaml"

echo "WebUI setup complete."
