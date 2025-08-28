#!/bin/bash

KUBE_APISERVER_MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

# 1. Verify the etcd server port in the manifest
echo "Verifying kube-apiserver manifest..."
if ! grep -q "--etcd-servers=https://127.0.0.1:2379" "$KUBE_APISERVER_MANIFEST"; then
    echo "Verification FAILED: The '--etcd-servers' flag in $KUBE_APISERVER_MANIFEST is not pointing to the correct client port (2379)."
    exit 1
fi
echo "OK: kube-apiserver manifest is configured correctly."

# 2. Verify that the API server is responsive
echo "Waiting for the kube-apiserver to become responsive..."
ATTEMPTS=0
MAX_ATTEMPTS=30 # Wait for up to 150 seconds (30 * 5s)
while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if kubectl get nodes > /dev/null 2>&1; then
        echo "OK: kube-apiserver is responsive."
        echo "done"
        exit 0
    fi
    echo "API server not ready yet, retrying in 5 seconds..."
    ATTEMPTS=$((ATTEMPTS + 1))
    sleep 5
done

echo "Verification FAILED: Timed out waiting for the kube-apiserver to become responsive."
exit 1
