#!/bin/bash

NAMESPACE="priority"

# 1. Check for PriorityClass existence
if ! kubectl get priorityclass high-priority &> /dev/null; then
  echo "Error: PriorityClass 'high-priority' not found."
  exit 1
fi

# 2. Check PriorityClass value is correct (one less than super-high-priority)
HIGHEST_PC_VALUE=$(kubectl get priorityclass super-high-priority -o jsonpath='{.value}')
EXPECTED_PC_VALUE=$((HIGHEST_PC_VALUE - 1))
ACTUAL_PC_VALUE=$(kubectl get priorityclass high-priority -o jsonpath='{.value}')

if [ "$ACTUAL_PC_VALUE" != "$EXPECTED_PC_VALUE" ]; then
  echo "Error: PriorityClass 'high-priority' has incorrect value. Expected $EXPECTED_PC_VALUE, got $ACTUAL_PC_VALUE."
  exit 1
fi

# 3. Check Deployment patch
DEPLOY_PC_NAME=$(kubectl get deployment busybox-logger -n $NAMESPACE -o jsonpath='{.spec.template.spec.priorityClassName}')
if [ "$DEPLOY_PC_NAME" != "high-priority" ]; then
  echo "Error: Deployment 'busybox-logger' is not using the 'high-priority' PriorityClass. Current value: $DEPLOY_PC_NAME"
  exit 1
fi

# 4. Check that the busybox-logger deployment is now running
# We give it 30 seconds to stabilize after the change
kubectl wait --for=condition=available --timeout=30s deployment/busybox-logger -n $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Deployment 'busybox-logger' did not become available after applying the PriorityClass."
    exit 1
fi

# 5. Check that the resource-hog pod was evicted (0 replicas available)
EVICTED_REPLICAS=$(kubectl get deployment resource-hog -n $NAMESPACE -o jsonpath='{.status.availableReplicas}')
if [ ! -z "$EVICTED_REPLICAS" ] && [ "$EVICTED_REPLICAS" -ne 0 ]; then
    echo "Error: The 'resource-hog' deployment still has available replicas. Preemption did not occur as expected."
    exit 1
fi

echo "done"
exit 0
