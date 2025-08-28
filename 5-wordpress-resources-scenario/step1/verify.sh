#!/bin/bash

NAMESPACE="wordpress"
DEPLOYMENT="wordpress"
EXPECTED_REPLICAS=3
EXPECTED_CPU="500m"
EXPECTED_MEM="500Mi"

# Check replica count
CURRENT_REPLICAS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.replicas}')
if [ "$CURRENT_REPLICAS" != "$EXPECTED_REPLICAS" ]; then
  echo "Error: Deployment has $CURRENT_REPLICAS replicas, but expected $EXPECTED_REPLICAS."
  exit 1
fi

# Check main container resources
CPU_REQ=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
MEM_REQ=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
CPU_LIMIT=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}')
MEM_LIMIT=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')

if [ "$CPU_REQ" != "$EXPECTED_CPU" ] || [ "$MEM_REQ" != "$EXPECTED_MEM" ] || [ "$CPU_LIMIT" != "$EXPECTED_CPU" ] || [ "$MEM_LIMIT" != "$EXPECTED_MEM" ]; then
  echo "Error: Resource settings for the main 'wordpress' container are incorrect."
  echo "Expected Requests: cpu=$EXPECTED_CPU, memory=$EXPECTED_MEM"
  echo "Expected Limits:   cpu=$EXPECTED_CPU, memory=$EXPECTED_MEM"
  exit 1
fi

# Check init container resources
INIT_CPU_REQ=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.cpu}')
INIT_MEM_REQ=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.memory}')
INIT_CPU_LIMIT=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.initContainers[0].resources.limits.cpu}')
INIT_MEM_LIMIT=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.initContainers[0].resources.limits.memory}')

if [ "$INIT_CPU_REQ" != "$EXPECTED_CPU" ] || [ "$INIT_MEM_REQ" != "$EXPECTED_MEM" ] || [ "$INIT_CPU_LIMIT" != "$EXPECTED_CPU" ] || [ "$INIT_MEM_LIMIT" != "$EXPECTED_MEM" ]; then
  echo "Error: Resource settings for the 'wait-for-mysql' initContainer are incorrect."
  echo "Expected Requests: cpu=$EXPECTED_CPU, memory=$EXPECTED_MEM"
  echo "Expected Limits:   cpu=$EXPECTED_CPU, memory=$EXPECTED_MEM"
  exit 1
fi

echo "done"
exit 0
