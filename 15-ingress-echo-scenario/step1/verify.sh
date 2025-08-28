#!/bin/bash

NAMESPACE="echo-sound"
INGRESS_NAME="echo"

# 1. Check if the Ingress resource exists
if ! kubectl get ingress $INGRESS_NAME -n $NAMESPACE &> /dev/null; then
    echo "Error: Ingress '$INGRESS_NAME' not found in namespace '$NAMESPACE'."
    exit 1
fi

# 2. Validate Ingress configuration
HOST=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o jsonpath='{.spec.rules[0].host}')
if [ "$HOST" != "example.org" ]; then
    echo "Error: Ingress host is not 'example.org'. Found: '$HOST'."
    exit 1
fi

PATH=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o jsonpath='{.spec.rules[0].http.paths[0].path}')
if [[ "$PATH" != *"/echo"* ]]; then
    echo "Error: Ingress path is not '/echo'. Found: '$PATH'."
    exit 1
fi

SERVICE_NAME=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
if [ "$SERVICE_NAME" != "echoserver-service" ]; then
    echo "Error: Ingress does not route to 'echoserver-service'. Found: '$SERVICE_NAME'."
    exit 1
fi

SERVICE_PORT=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')
if [ "$SERVICE_PORT" != "8080" ]; then
    echo "Error: Ingress does not route to service port 8080. Found: '$SERVICE_PORT'."
    exit 1
fi

# 3. Wait for ingress controller to apply changes and test connectivity
echo "Waiting for Ingress to be provisioned..."
sleep 15

HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" http://example.org/echo)
if [ "$HTTP_CODE" != "200" ]; then
    echo "Error: Request to http://example.org/echo failed with HTTP code $HTTP_CODE. Expected 200."
    exit 1
fi

echo "done"
exit 0
