#!/bin/bash

# Install cert-manager, which includes its CRDs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml

# Wait for the cert-manager webhook to be ready to ensure CRDs are registered and available
echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
echo "cert-manager is ready."
