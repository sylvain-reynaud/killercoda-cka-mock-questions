#!/bin/bash

# 1. Verify Helm repository was added
echo "Verifying Helm repository..."
if ! helm repo list | grep -q "^argo\s"; then
    echo "Verification FAILED: Helm repository 'argo' not found."
    exit 1
fi
echo "OK: Helm repository 'argo' was added."

# 2. Verify Helm template file was created
TEMPLATE_FILE="/argo-helm.yaml"
echo "Verifying Helm template file..."
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Verification FAILED: Template file '$TEMPLATE_FILE' not found."
    exit 1
fi
echo "OK: Template file '$TEMPLATE_FILE' found."

# 3. Verify template file configuration (no CRDs, correct namespace)
echo "Verifying template file contents..."
if grep -q "kind: CustomResourceDefinition" "$TEMPLATE_FILE"; then
    echo "Verification FAILED: Template file '$TEMPLATE_FILE' incorrectly contains CRDs. Was '--set crds.install=false' used?"
    exit 1
fi
if ! grep -q "namespace: argocd" "$TEMPLATE_FILE"; then
    echo "Verification FAILED: Template file '$TEMPLATE_FILE' does not appear to be for the 'argocd' namespace."
    exit 1
fi
echo "OK: Template file is configured correctly."

# 4. Verify Helm release is installed
echo "Verifying Helm release installation..."
if ! helm status argocd -n argocd > /dev/null 2>&1; then
    echo "Verification FAILED: Helm release 'argocd' not found in namespace 'argocd'."
    exit 1
fi
echo "OK: Helm release 'argocd' is installed."

# 5. Verify release configuration (no CRDs)
echo "Verifying release configuration..."
INSTALL_CRDS_VALUE=$(helm get values argocd -n argocd -o json | jq -r '.crds.install')
if [ "$INSTALL_CRDS_VALUE" != "false" ]; then
    echo "Verification FAILED: The 'argocd' release was not configured with 'crds.install=false'."
    exit 1
fi
echo "OK: Release is configured to not install CRDs."

echo "done"
exit 0
