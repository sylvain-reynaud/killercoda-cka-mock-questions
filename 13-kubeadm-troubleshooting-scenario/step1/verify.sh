#!/bin/bash

# Give the cluster a moment to stabilize after the user's fixes
echo "Waiting for cluster to stabilize..."
sleep 30

# 1. Check if the node is in a Ready state
NODE_STATUS=$(kubectl get nodes -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}')
if [ "$NODE_STATUS" != "True" ]; then
    echo "Error: The node is not in a 'Ready' state. Please check node status and kubelet logs."
    kubectl get nodes
    exit 1
fi

# 2. Check that all pods in kube-system are Running or have Succeeded
FAILED_PODS=false
for status in $(kubectl get pods -n kube-system -o jsonpath='{.items[*].status.phase}'); do
    if [[ "$status" != "Running" && "$status" != "Succeeded" ]]; then
        echo "Error: A pod in the kube-system namespace is not in a 'Running' or 'Succeeded' state."
        FAILED_PODS=true
    fi
done

if [ "$FAILED_PODS" = true ]; then
    echo "Dumping status of kube-system pods:"
    kubectl get pods -n kube-system
    exit 1
fi

echo "done"
exit 0
