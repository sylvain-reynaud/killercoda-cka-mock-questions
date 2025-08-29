#!/bin/bash

NAMESPACE="mariadb"
PVC_NAME="mariadb"
DEPLOY_NAME="mariadb"

# 1. Check if the PVC exists
if ! kubectl get pvc $PVC_NAME -n $NAMESPACE &> /dev/null; then
    echo "Error: PersistentVolumeClaim '$PVC_NAME' not found in namespace '$NAMESPACE'."
    exit 1
fi

# 2. Check PVC specs
PVC_STATUS=$(kubectl get pvc $PVC_NAME -n $NAMESPACE -o jsonpath='{.status.phase}')
if [ "$PVC_STATUS" != "Bound" ]; then
    echo "Error: PVC '$PVC_NAME' is not in a 'Bound' state. Current state: $PVC_STATUS."
    exit 1
fi

PVC_ACCESS_MODE=$(kubectl get pvc $PVC_NAME -n $NAMESPACE -o jsonpath='{.spec.accessModes[0]}')
if [ "$PVC_ACCESS_MODE" != "ReadWriteOnce" ]; then
    echo "Error: PVC '$PVC_NAME' has incorrect access mode. Expected 'ReadWriteOnce', got '$PVC_ACCESS_MODE'."
    exit 1
fi

PVC_STORAGE=$(kubectl get pvc $PVC_NAME -n $NAMESPACE -o jsonpath='{.spec.resources.requests.storage}')
if [ "$PVC_STORAGE" != "250Mi" ]; then
    echo "Error: PVC '$PVC_NAME' has incorrect storage capacity. Expected '250Mi', got '$PVC_STORAGE'."
    exit 1
fi

# 3. Check if the deployment exists
if ! kubectl get deployment $DEPLOY_NAME -n $NAMESPACE &> /dev/null; then
    echo "Error: Deployment '$DEPLOY_NAME' not found in namespace '$NAMESPACE'. Did you apply the manifest from ~/mariadb-deploy.yaml?"
    exit 1
fi

# 4. Check if the deployment is using the PVC
VOLUME_PVC_NAME=$(kubectl get deployment $DEPLOY_NAME -n $NAMESPACE -o jsonpath='{.spec.template.spec.volumes[?(@.persistentVolumeClaim.claimName=="mariadb")].persistentVolumeClaim.claimName}')
if [ -z "$VOLUME_PVC_NAME" ]; then
    echo "Error: Deployment '$DEPLOY_NAME' is not configured to use the '$PVC_NAME' PersistentVolumeClaim in its volumes."
    exit 1
fi

# 5. Check if the deployment is stable and running
kubectl wait --for=condition=available --timeout=60s deployment/$DEPLOY_NAME -n $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Deployment '$DEPLOY_NAME' did not become available. Check its status and events."
    exit 1
fi

echo "done"
exit 0
