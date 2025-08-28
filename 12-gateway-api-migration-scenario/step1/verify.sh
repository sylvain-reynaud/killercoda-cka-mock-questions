#!/bin/bash

NAMESPACE="gateway-migration"
GATEWAY_NAME="web-gateway"
ROUTE_NAME="web-route"

# 1. Check if the Gateway resource exists
if ! kubectl get gateway $GATEWAY_NAME -n $NAMESPACE &> /dev/null; then
    echo "Error: Gateway '$GATEWAY_NAME' not found in namespace '$NAMESPACE'."
    exit 1
fi

# 2. Validate Gateway configuration
GW_CLASS=$(kubectl get gateway $GATEWAY_NAME -n $NAMESPACE -o jsonpath='{.spec.gatewayClassName}')
if [ "$GW_CLASS" != "nginx-class" ]; then
    echo "Error: Gateway is not using 'nginx-class'. Found: '$GW_CLASS'."
    exit 1
fi

LISTENER_HOSTNAME=$(kubectl get gateway $GATEWAY_NAME -n $NAMESPACE -o jsonpath='{.spec.listeners[0].hostname}')
if [ "$LISTENER_HOSTNAME" != "gateway.web.k8s.local" ]; then
    echo "Error: Gateway listener hostname is not 'gateway.web.k8s.local'. Found: '$LISTENER_HOSTNAME'."
    exit 1
fi

LISTENER_PORT=$(kubectl get gateway $GATEWAY_NAME -n $NAMESPACE -o jsonpath='{.spec.listeners[0].port}')
if [ "$LISTENER_PORT" != "443" ]; then
    echo "Error: Gateway listener is not on port 443. Found: '$LISTENER_PORT'."
    exit 1
fi

LISTENER_PROTOCOL=$(kubectl get gateway $GATEWAY_NAME -n $NAMESPACE -o jsonpath='{.spec.listeners[0].protocol}')
if [ "$LISTENER_PROTOCOL" != "HTTPS" ]; then
    echo "Error: Gateway listener protocol is not HTTPS. Found: '$LISTENER_PROTOCOL'."
    exit 1
fi

TLS_SECRET=$(kubectl get gateway $GATEWAY_NAME -n $NAMESPACE -o jsonpath='{.spec.listeners[0].tls.certificateRefs[0].name}')
if [ "$TLS_SECRET" != "web-tls" ]; then
    echo "Error: Gateway is not using the 'web-tls' secret. Found: '$TLS_SECRET'."
    exit 1
fi

# 3. Check if the HTTPRoute resource exists
if ! kubectl get httproute $ROUTE_NAME -n $NAMESPACE &> /dev/null; then
    echo "Error: HTTPRoute '$ROUTE_NAME' not found in namespace '$NAMESPACE'."
    exit 1
fi

# 4. Validate HTTPRoute configuration
PARENT_GATEWAY=$(kubectl get httproute $ROUTE_NAME -n $NAMESPACE -o jsonpath='{.spec.parentRefs[0].name}')
if [ "$PARENT_GATEWAY" != "$GATEWAY_NAME" ]; then
    echo "Error: HTTPRoute is not attached to the '$GATEWAY_NAME' Gateway. Found: '$PARENT_GATEWAY'."
    exit 1
fi

ROUTE_HOSTNAME=$(kubectl get httproute $ROUTE_NAME -n $NAMESPACE -o jsonpath='{.spec.hostnames[0]}')
if [ "$ROUTE_HOSTNAME" != "gateway.web.k8s.local" ]; then
    echo "Error: HTTPRoute hostname is not 'gateway.web.k8s.local'. Found: '$ROUTE_HOSTNAME'."
    exit 1
fi

BACKEND_SERVICE=$(kubectl get httproute $ROUTE_NAME -n $NAMESPACE -o jsonpath='{.spec.rules[0].backendRefs[0].name}')
if [ "$BACKEND_SERVICE" != "web-service" ]; then
    echo "Error: HTTPRoute does not route to 'web-service'. Found: '$BACKEND_SERVICE'."
    exit 1
fi

BACKEND_PORT=$(kubectl get httproute $ROUTE_NAME -n $NAMESPACE -o jsonpath='{.spec.rules[0].backendRefs[0].port}')
if [ "$BACKEND_PORT" != "80" ]; then
    echo "Error: HTTPRoute does not route to port 80. Found: '$BACKEND_PORT'."
    exit 1
fi

echo "done"
exit 0
