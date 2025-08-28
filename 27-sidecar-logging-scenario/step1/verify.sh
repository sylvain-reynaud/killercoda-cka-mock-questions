#!/bin/bash

DEPLOYMENT="synergy-deployment"

# 1. Verify there are two containers
echo "Verifying container count..."
CONTAINER_COUNT=$(kubectl get deployment "$DEPLOYMENT" -o jsonpath='{.spec.template.spec.containers[*].name}' | wc -w)
if [ "$CONTAINER_COUNT" -ne 2 ]; then
    echo "Verification FAILED: Expected 2 containers in the deployment, but found $CONTAINER_COUNT."
    exit 1
fi
echo "OK: Found 2 containers."

# 2. Verify sidecar container configuration
echo "Verifying sidecar container..."
SIDECAR_IMAGE=$(kubectl get deployment "$DEPLOYMENT" -o jsonpath="{.spec.template.spec.containers[?(@.name=='sidecar')].image}")
if [ "$SIDECAR_IMAGE" != "busybox:stable" ]; then
    echo "Verification FAILED: Sidecar container is not using the 'busybox:stable' image."
    exit 1
fi

SIDECAR_CMD=$(kubectl get deployment "$DEPLOYMENT" -o jsonpath="{.spec.template.spec.containers[?(@.name=='sidecar')].command[2]}")
SIDECAR_ARG=$(kubectl get deployment "$DEPLOYMENT" -o jsonpath="{.spec.template.spec.containers[?(@.name=='sidecar')].args[0]}")
EXPECTED_CMD_ARG="tail -n+1 -f /var/log/synergy-deployment.log"

if [[ "$SIDECAR_CMD" != "$EXPECTED_CMD_ARG" && "$SIDECAR_ARG" != "$EXPECTED_CMD_ARG" ]]; then
    echo "Verification FAILED: Sidecar container is not running the correct command/args."
    exit 1
fi
echo "OK: Sidecar container is configured correctly."

# 3. Verify shared volume and mounts
echo "Verifying shared volume and mounts..."
VOLUME_NAME=$(kubectl get deployment "$DEPLOYMENT" -o jsonpath="{.spec.template.spec.containers[?(@.name=='sidecar')].volumeMounts[?(@.mountPath=='/var/log')].name}")
if [ -z "$VOLUME_NAME" ]; then
    echo "Verification FAILED: Sidecar container does not have a volume mounted at /var/log."
    exit 1
fi

APP_VOLUME_MOUNT=$(kubectl get deployment "$DEPLOYMENT" -o jsonpath="{.spec.template.spec.containers[?(@.name=='synergy-app')].volumeMounts[?(@.mountPath=='/var/log')].name}")
if [ "$APP_VOLUME_MOUNT" != "$VOLUME_NAME" ]; then
    echo "Verification FAILED: The main app container and sidecar do not share the same volume at /var/log."
    exit 1
fi

VOLUME_EXISTS=$(kubectl get deployment "$DEPLOYMENT" -o jsonpath="{.spec.template.spec.volumes[?(@.name=='$VOLUME_NAME')].name}")
if [ -z "$VOLUME_EXISTS" ]; then
    echo "Verification FAILED: The shared volume '$VOLUME_NAME' is not defined in the pod spec."
    exit 1
fi
echo "OK: Shared volume and mounts are configured correctly."

echo "done"
exit 0
