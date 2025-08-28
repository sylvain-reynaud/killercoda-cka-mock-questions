#!/bin/bash

NODE_NAME="controlplane"
POD_NAME="tolerating-pod"

# 1. Verify the taint on the node
echo "Verifying taint on node '$NODE_NAME'..."
TAINT_EXISTS=$(kubectl get node "$NODE_NAME" -o jsonpath='{.spec.taints[?(@.key=="IT" && @.value=="Kiddie" && @.effect=="NoSchedule")]}')
if [ -z "$TAINT_EXISTS" ]; then
    echo "Verification FAILED: The taint 'IT=Kiddie:NoSchedule' was not found on node '$NODE_NAME'."
    exit 1
fi
echo "OK: Taint is correctly applied to node '$NODE_NAME'."

# 2. Verify the pod exists and has the correct toleration
echo "Verifying pod '$POD_NAME' exists..."
if ! kubectl get pod "$POD_NAME" > /dev/null 2>&1; then
    echo "Verification FAILED: Pod '$POD_NAME' not found."
    exit 1
fi
echo "OK: Pod '$POD_NAME' found."

echo "Verifying toleration on pod '$POD_NAME'..."
TOLERATION_EXISTS=$(kubectl get pod "$POD_NAME" -o jsonpath='{.spec.tolerations[?(@.key=="IT" && @.operator=="Equal" && @.value=="Kiddie" && @.effect=="NoSchedule")]}')
if [ -z "$TOLERATION_EXISTS" ]; then
    echo "Verification FAILED: Pod '$POD_NAME' does not have the required toleration for 'IT=Kiddie:NoSchedule'."
    exit 1
fi
echo "OK: Pod '$POD_NAME' has the correct toleration."

# 3. Verify the pod is scheduled on the correct node
echo "Verifying pod '$POD_NAME' is scheduled on '$NODE_NAME'..."
POD_NODE=$(kubectl get pod "$POD_NAME" -o jsonpath='{.spec.nodeName}')
if [ "$POD_NODE" != "$NODE_NAME" ]; then
    echo "Verification FAILED: Pod '$POD_NAME' is scheduled on node '$POD_NODE', but expected '$NODE_NAME'."
    exit 1
fi
echo "OK: Pod '$POD_NAME' is scheduled on the correct node."

echo "done"
exit 0
