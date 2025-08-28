#!/bin/bash

NAMESPACE="nodeport-expose"
DEPLOYMENT_NAME="nodeport-deployment"
SERVICE_NAME="nodeport-service"

# 1. Check if the deployment's container port is configured
CONTAINER_PORT=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')
if [ "$CONTAINER_PORT" != "80" ]; then
    echo "Error: Deployment '$DEPLOYMENT_NAME' containerPort is not '80'. Found: '$CONTAINER_PORT'."
    exit 1
fi

PORT_PROTOCOL=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].ports[0].protocol}')
if [ "$PORT_PROTOCOL" != "TCP" ]; then
    echo "Error: Deployment port protocol is not 'TCP'. Found: '$PORT_PROTOCOL'."
    exit 1
fi

PORT_NAME=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].ports[0].name}')
if [ "$PORT_NAME" != "http" ]; then
    echo "Error: Deployment port name is not 'http'. Found: '$PORT_NAME'."
    exit 1
fi

# 2. Check if the service exists
if ! kubectl get service $SERVICE_NAME -n $NAMESPACE &> /dev/null; then
    echo "Error: Service '$SERVICE_NAME' not found in namespace '$NAMESPACE'."
    exit 1
fi

# 3. Check service type
SERVICE_TYPE=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.type}')
if [ "$SERVICE_TYPE" != "NodePort" ]; then
    echo "Error: Service '$SERVICE_NAME' is not of type 'NodePort'. Found: '$SERVICE_TYPE'."
    exit 1
fi

# 4. Check service ports
SERVICE_PORT=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.ports[0].port}')
if [ "$SERVICE_PORT" != "80" ]; then
    echo "Error: Service port is not '80'. Found: '$SERVICE_PORT'."
    exit 1
fi

TARGET_PORT=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.ports[0].targetPort}')
if [[ "$TARGET_PORT" != "80" && "$TARGET_PORT" != "http" ]]; then
    echo "Error: Service targetPort is not '80' or 'http'. Found: '$TARGET_PORT'."
    exit 1
fi

# 5. Check if the service selector is correct
SELECTOR_APP=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.selector.app}')
if [ "$SELECTOR_APP" != "nodeport-app" ]; then
    echo "Error: Service selector does not match 'app: nodeport-app'."
    exit 1
fi

echo "done"
exit 0
