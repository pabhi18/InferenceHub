#!/bin/bash
set -e

echo "Installing Istio (CRDs + control plane + ingress)..."
istioctl install --set profile=default -y

echo "Ensuring Istio ingress gateway is LoadBalancer..."
kubectl patch svc istio-ingressgateway -n istio-system \
  -p '{"spec": {"type": "LoadBalancer"}}'

echo "Applying Istio Gateway CR..."
kubectl apply -f istio/gateway/platform-gateway.yaml

echo "Done."