#!/bin/bash

NAMESPACE="backend"
CORRECT_POLICY_NAME="allow-frontend-to-backend"

# 1. Check that the original 'default-deny-all' policy is untouched.
if ! kubectl get networkpolicy default-deny-all -n $NAMESPACE &> /dev/null; then
    echo "Error: The 'default-deny-all' network policy was deleted. It should not be modified."
    exit 1
fi

# 2. Check that the single correct policy was applied.
if ! kubectl get networkpolicy $CORRECT_POLICY_NAME -n $NAMESPACE &> /dev/null; then
    echo "Error: The correct network policy, '$CORRECT_POLICY_NAME', was not found."
    echo "Please select and apply the most restrictive, correct policy from the ~/netpol directory."
    exit 1
fi

# 3. Check that no other, incorrect policies were applied.
POLICY_COUNT=$(kubectl get networkpolicies -n $NAMESPACE --no-headers | wc -l)
if [ "$POLICY_COUNT" -ne 2 ]; then
    echo "Error: Expected exactly 2 policies in the '$NAMESPACE' namespace (default-deny-all and the one you added), but found $POLICY_COUNT."
    echo "Please ensure only the single, correct policy is applied."
    kubectl get networkpolicies -n $NAMESPACE
    exit 1
fi

echo "done"
exit 0
