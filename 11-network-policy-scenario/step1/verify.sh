#!/bin/bash

NAMESPACE="backend"
POLICY_NAME="allow-frontend"

# 1. Check if the NetworkPolicy exists
if ! kubectl get networkpolicy $POLICY_NAME -n $NAMESPACE &> /dev/null; then
    echo "Error: NetworkPolicy '$POLICY_NAME' not found in namespace '$NAMESPACE'."
    exit 1
fi

# 2. Check if the policy applies to the correct pods
POD_SELECTOR=$(kubectl get networkpolicy $POLICY_NAME -n $NAMESPACE -o jsonpath='{.spec.podSelector.matchLabels.app}')
if [ "$POD_SELECTOR" != "backend" ]; then
    echo "Error: NetworkPolicy does not apply to pods with label 'app: backend'."
    exit 1
fi

# 3. Check for correct ingress rule configuration
# Check namespace selector
NS_SELECTOR=$(kubectl get networkpolicy $POLICY_NAME -n $NAMESPACE -o jsonpath='{.spec.ingress[0].from[0].namespaceSelector.matchLabels.name}')
if [ "$NS_SELECTOR" != "frontend" ]; then
    echo "Error: Ingress rule does not select the 'frontend' namespace correctly."
    exit 1
fi

# Check pod selector within the ingress rule
INGRESS_POD_SELECTOR=$(kubectl get networkpolicy $POLICY_NAME -n $NAMESPACE -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.app}')
if [ "$INGRESS_POD_SELECTOR" != "frontend" ]; then
    echo "Error: Ingress rule does not select pods with label 'app: frontend'."
    exit 1
fi

# 4. Check for correct port and protocol
PORT=$(kubectl get networkpolicy $POLICY_NAME -n $NAMESPACE -o jsonpath='{.spec.ingress[0].ports[0].port}')
if [ "$PORT" != "80" ]; then
    echo "Error: Ingress rule does not allow traffic on port 80."
    exit 1
fi

PROTOCOL=$(kubectl get networkpolicy $POLICY_NAME -n $NAMESPACE -o jsonpath='{.spec.ingress[0].ports[0].protocol}')
if [ "$PROTOCOL" != "TCP" ]; then
    echo "Error: Ingress rule does not specify TCP protocol."
    exit 1
fi

# 5. Ensure it's ingress-only (least permissive)
POLICY_TYPES=$(kubectl get networkpolicy $POLICY_NAME -n $NAMESPACE -o jsonpath='{.spec.policyTypes}')
if [[ "$POLICY_TYPES" != *"Ingress"* || "$POLICY_TYPES" == *"Egress"* ]]; then
    echo "Error: NetworkPolicy should only define 'Ingress' policy type."
    exit 1
fi

echo "done"
exit 0
