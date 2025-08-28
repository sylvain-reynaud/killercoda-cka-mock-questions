#!/bin/bash

NAMESPACE="sp-culator"
DEPLOYMENT_NAME="front-end"
SERVICE_NAME="front-end-svc"

# 1. Verify the Deployment has been reconfigured correctly
CONTAINER_PORT=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')

if [ -z "$CONTAINER_PORT" ]; then
    echo "Error: The container port is not exposed in the '$DEPLOYMENT_NAME' deployment."
    exit 1
fi

if [ "$CONTAINER_PORT" -ne 80 ]; then
    echo "Error: The exposed container port is '$CONTAINER_PORT', but it should be '80'."
    exit 1
fi

# 2. Verify the Service has been created correctly
if ! kubectl get service $SERVICE_NAME -n $NAMESPACE &> /dev/null; then
    echo "Error: Service '$SERVICE_NAME' not found in namespace '$NAMESPACE'."
    exit 1
fi

SERVICE_TYPE=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.type}')
if [ "$SERVICE_TYPE" != "NodePort" ]; then
    echo "Error: Service type is '$SERVICE_TYPE', but it should be 'NodePort'."
    exit 1
fi

SERVICE_PORT=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.ports[0].port}')
if [ "$SERVICE_PORT" -ne 80 ]; then
    echo "Error: Service port is '$SERVICE_PORT', but it should be '80'."
    exit 1
fi

TARGET_PORT=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.ports[0].targetPort}')
if [ "$TARGET_PORT" -ne 80 ]; then
    echo "Error: Service targetPort is '$TARGET_PORT', but it should be '80'."
    exit 1
fi

# 3. Check if the service selector matches the deployment labels
SELECTOR=$(kubectl get svc $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.selector.app}')
if [ "$SELECTOR" != "front-end" ]; then
    echo "Error: Service selector does not match 'app: front-end'."
    exit 1
fi

echo "done"
exit 0
