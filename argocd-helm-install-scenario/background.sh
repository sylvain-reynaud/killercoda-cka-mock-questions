#!/bin/bash

# Create the target namespace and directory
mkdir -p /home/argo
kubectl create namespace argocd

# Add the argo repo temporarily to fetch the CRDs
helm repo add argo https://argoproj.github.io/argo-helm &> /dev/null
helm repo update &> /dev/null

# The argo-cd chart allows installing CRDs separately.
# We will pre-install them as per the scenario's requirements.
helm template argo/argo-cd --version 7.7.3 --namespace argocd --set crds.install=true --show-only templates/crds.yaml | kubectl apply -f -

# Remove the repo so the user has to add it themselves.
helm repo remove argo &> /dev/null
