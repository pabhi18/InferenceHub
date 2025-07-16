#!/bin/bash

set -e

echo "Setting up namespaces..."
kubectl apply -f infrastructure/namespaces/model-1-namespace.yaml
kubectl apply -f infrastructure/namespaces/model-2-namespace.yaml
kubectl apply -f infrastructure/namespaces/model-3-namespace.yaml

echo "Setting up storage classes..."
kubectl apply -f infrastructure/storage-classes/storageclass.yaml

echo "Cluster setup complete..."
