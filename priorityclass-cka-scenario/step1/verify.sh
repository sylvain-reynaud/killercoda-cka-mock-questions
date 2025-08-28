#!/bin/bash

# Check for PriorityClass existence
if ! kubectl get priorityclass high-priority &> /dev/null; then
  echo "PriorityClass 'high-priority' not found."
  exit 1
fi

# Check PriorityClass value
PC_VALUE=$(kubectl get priorityclass high-priority -o jsonpath='{.value}')
if [ "$PC_VALUE" != "999999" ]; then
  echo "PriorityClass 'high-priority' has incorrect value. Expected 999999, got $PC_VALUE"
  exit 1
fi

# Check Deployment patch
DEPLOY_PC_NAME=$(kubectl get deployment busybox-logger -n priority -o jsonpath='{.spec.template.spec.priorityClassName}')
if [ "$DEPLOY_PC_NAME" != "high-priority" ]; then
  echo "Deployment 'busybox-logger' is not using the 'high-priority' PriorityClass. Current value: $DEPLOY_PC_NAME"
  exit 1
fi

echo "done"
exit 0
