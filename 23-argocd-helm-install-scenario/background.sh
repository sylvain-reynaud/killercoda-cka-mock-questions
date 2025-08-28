#!/bin/bash

# The exercise requires Argo CD CRDs for chart version 7.7.3 to be pre-installed.
# We will apply them directly from the raw GitHub source for that tag.

CRD_BASE_URL="https://raw.githubusercontent.com/argoproj/argo-helm/argo-cd-7.7.3/charts/argo-cd/crds"

echo "Installing Argo CD CRDs..."

kubectl apply -f ${CRD_BASE_URL}/crd-application.yaml
kubectl apply -f ${CRD_BASE_URL}/crd-applicationset.yaml
kubectl apply -f ${CRD_BASE_URL}/crd-appproject.yaml

echo "Argo CD CRDs have been pre-installed."
