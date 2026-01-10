#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: ./setup-certs.sh <CLOUDFLARE_API_TOKEN>"
  exit 1
fi

CLOUDFLARE_API_TOKEN="$1"

echo "Setting up cert-manager and TLS certificates..."

if ! kubectl get ns cert-manager >/dev/null 2>&1; then
  echo "Installing cert-manager..."
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
fi

echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=Available deployment/cert-manager -n cert-manager --timeout=180s
kubectl wait --for=condition=Available deployment/cert-manager-webhook -n cert-manager --timeout=180s

echo "Creating Cloudflare API token secret..."
kubectl create secret generic cloudflare-api-token \
  -n cert-manager \
  --from-literal=api-token="${CLOUDFLARE_API_TOKEN}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Applying ClusterIssuer..."
kubectl apply -f certs/clusterissuer.yaml

echo "Waiting for ClusterIssuer to become ready..."
kubectl wait --for=condition=Ready clusterissuer/letsencrypt-cloudflare --timeout=180s

echo "Applying Certificate..."
kubectl apply -f certs/certificate.yaml

echo "Waiting for Certificate to become ready..."
CERT_NAME=$(kubectl get certificate -n istio-system -o jsonpath='{.items[0].metadata.name}')
kubectl wait --for=condition=Ready certificate/${CERT_NAME} -n istio-system --timeout=300s

echo "Certificate setup completed successfully."
