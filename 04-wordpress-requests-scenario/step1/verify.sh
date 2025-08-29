#!/bin/bash

NAMESPACE="relative-fawn"
DEPLOYMENT="wordpress"
EXPECTED_REPLICAS=3
EXPECTED_CPU_REQ="250m"
EXPECTED_MEM_REQ="500Mi"

# Check replica count
CURRENT_REPLICAS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.replicas}')
if [ "$CURRENT_REPLICAS" != "$EXPECTED_REPLICAS" ]; then
  echo "Error: Deployment has $CURRENT_REPLICAS replicas, but expected $EXPECTED_REPLICAS."
  exit 1
fi

# Check ready replica count
READY_REPLICAS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
if [ "$READY_REPLICAS" != "$EXPECTED_REPLICAS" ]; then
  echo "Error: Deployment has $READY_REPLICAS ready replicas, but expected $EXPECTED_REPLICAS. Please wait for all pods to be ready."
  exit 1
fi

# Check main container resource requests
CPU_REQ=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
MEM_REQ=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')

if [ "$CPU_REQ" != "$EXPECTED_CPU_REQ" ] || [ "$MEM_REQ" != "$EXPECTED_MEM_REQ" ]; then
  echo "Error: Resource requests for the main 'wordpress' container are incorrect."
  echo "Expected Requests: cpu=$EXPECTED_CPU_REQ, memory=$EXPECTED_MEM_REQ"
  echo "Found Requests:    cpu=$CPU_REQ, memory=$MEM_REQ"
  exit 1
fi

# Check init container resource requests
INIT_CPU_REQ=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.cpu}')
INIT_MEM_REQ=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.memory}')

if [ "$INIT_CPU_REQ" != "$EXPECTED_CPU_REQ" ] || [ "$INIT_MEM_REQ" != "$EXPECTED_MEM_REQ" ]; then
  echo "Error: Resource requests for the 'wait-for-mysql' initContainer are incorrect."
  echo "Expected Requests: cpu=$EXPECTED_CPU_REQ, memory=$EXPECTED_MEM_REQ"
  echo "Found Requests:    cpu=$INIT_CPU_REQ, memory=$INIT_MEM_REQ"
  exit 1
fi

echo "done"
exit 0
