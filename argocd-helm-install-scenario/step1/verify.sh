#!/bin/bash

MANIFEST_PATH="/home/argo/argo.helm.yaml"

# 1. Check if the argo helm repository was added
if ! helm repo list | grep -q -E "^argo\s+https://argoproj.github.io/argo-helm"; then
    echo "Error: Helm repository 'argo' with URL 'https://argoproj.github.io/argo-helm' not found."
    exit 1
fi

# 2. Check if the manifest file exists
if [ ! -f "$MANIFEST_PATH" ]; then
    echo "Error: Manifest file not found at $MANIFEST_PATH."
    exit 1
fi

# 3. Check that the manifest does NOT contain CRDs
if grep -q -E "^kind: CustomResourceDefinition" "$MANIFEST_PATH"; then
    echo "Error: The manifest file at $MANIFEST_PATH should not contain resources of kind 'CustomResourceDefinition'."
    exit 1
fi

# 4. Check that the manifest contains key ArgoCD components for the correct namespace
# We check for the server deployment and ensure its namespace is argocd
if ! grep -q -E "^kind: Deployment" "$MANIFEST_PATH" || ! grep -q -E "name: argocd-server" "$MANIFEST_PATH"; then
    echo "Error: The manifest file does not appear to contain the Argo CD server Deployment."
    exit 1
fi

# Use yq to parse the namespace of the server deployment. If yq is not available, fallback to grep.
if command -v yq &> /dev/null; then
    SERVER_NS=$(yq '.metadata.namespace' "$MANIFEST_PATH" | grep 'argocd')
    if [[ -z "$SERVER_NS" ]]; then
        echo "Error: The argocd-server resource in the manifest is not targeted for the 'argocd' namespace."
        exit 1
    fi
else
    # Fallback to grep if yq is not installed in the environment
    if ! grep -A 5 "name: argocd-server" "$MANIFEST_PATH" | grep -q "namespace: argocd"; then
        echo "Error: The argocd-server resource in the manifest is not targeted for the 'argocd' namespace."
        exit 1
    fi
fi

echo "done"
exit 0
