#!/bin/bash

# 1. Verify that Calico was installed (as it's the only one that supports Network Policies)
echo "Verifying that Calico CNI was installed..."
if ! kubectl get namespace calico-system > /dev/null 2>&1; then
    echo "Verification FAILED: The 'calico-system' namespace was not found. It appears Calico was not installed, or the wrong CNI was chosen."
    exit 1
fi

if ! kubectl get daemonset calico-node -n calico-system > /dev/null 2>&1; then
    echo "Verification FAILED: The 'calico-node' daemonset was not found. It appears Calico was not installed correctly."
    exit 1
fi
echo "OK: Calico installation detected."

# 2. Wait for the node to become Ready
echo "Waiting for the control-plane node to become Ready..."
if ! kubectl wait --for=condition=Ready node --all --timeout=300s; then
    echo "Verification FAILED: Node did not become Ready after CNI installation."
    exit 1
fi
echo "OK: Node is Ready."

# 3. Verify Network Policy enforcement
echo "Verifying Network Policy enforcement..."
TEST_NS="cni-test"
kubectl create ns $TEST_NS

# Deploy two pods
kubectl run pod-a --image=busybox -n $TEST_NS -- sh -c 'sleep 3600'
kubectl run pod-b --image=busybox -n $TEST_NS -- sh -c 'sleep 3600'

# Wait for pods to be running
kubectl wait --for=condition=ready pod -n $TEST_NS --all --timeout=120s

POD_B_IP=$(kubectl get pod pod-b -n $TEST_NS -o jsonpath='{.status.podIP}')

# Initial connectivity test (should succeed)
echo "Testing initial connectivity..."
if ! kubectl exec pod-a -n $TEST_NS -- timeout 5 ping -c 1 $POD_B_IP > /dev/null 2>&1; then
    echo "Verification FAILED: Initial pod-to-pod communication failed."
    kubectl delete ns $TEST_NS > /dev/null 2>&1
    exit 1
fi
echo "OK: Initial pod-to-pod communication is working."

# Apply a deny-all ingress policy to pod-b
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: $TEST_NS
spec:
  podSelector:
    matchLabels:
      run: pod-b
  policyTypes:
  - Ingress
EOF

# Give the CNI a moment to enforce the policy
sleep 10

# Second connectivity test (should fail)
echo "Testing connectivity after applying deny-all NetworkPolicy..."
if kubectl exec pod-a -n $TEST_NS -- timeout 5 ping -c 1 $POD_B_IP > /dev/null 2>&1; then
    echo "Verification FAILED: NetworkPolicy was not enforced. Pod-to-pod communication still possible."
    kubectl delete ns $TEST_NS > /dev/null 2>&1
    exit 1
fi
echo "OK: NetworkPolicy correctly blocked communication."

# Cleanup
kubectl delete ns $TEST_NS > /dev/null 2>&1

echo "done"
exit 0
