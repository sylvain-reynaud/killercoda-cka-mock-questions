#!/bin/bash

# 1. Verify that Calico resources were created
echo "Verifying that Calico resources were created..."
if ! kubectl get namespace calico-system > /dev/null 2>&1; then
    echo "Verification FAILED: The 'calico-system' namespace was not found."
    exit 1
fi

if ! kubectl get daemonset calico-node -n calico-system > /dev/null 2>&1; then
    echo "Verification FAILED: The 'calico-node' daemonset was not found in the 'calico-system' namespace."
    exit 1
fi
echo "OK: Calico resources detected."

# 2. Wait for the node to become Ready
echo "Waiting for the control-plane node to become Ready..."
if ! kubectl wait --for=condition=Ready node --all --timeout=300s; then
    echo "Verification FAILED: Node did not become Ready after CNI installation."
    exit 1
fi
echo "OK: Node is Ready."

echo "done"
exit 0
