#!/bin/bash

NAMESPACE="wordpress-sidecar"
DEPLOYMENT="wordpress"

# 1. Check for the presence of the sidecar container
NUM_CONTAINERS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].name}' | wc -w)
if [ "$NUM_CONTAINERS" -ne 2 ]; then
    echo "Error: Expected 2 containers in the Pod, but found $NUM_CONTAINERS."
    exit 1
fi

SIDECAR_NAME=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[1].name}')
if [ "$SIDECAR_NAME" != "sidecar" ]; then
    echo "Error: The sidecar container is not named 'sidecar'. Found: '$SIDECAR_NAME'."
    exit 1
fi

# 2. Check sidecar container image and command
SIDECAR_IMAGE=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[1].image}')
if [ "$SIDECAR_IMAGE" != "busybox:stable" ]; then
    echo "Error: Sidecar container is not using the 'busybox:stable' image. Found: '$SIDECAR_IMAGE'."
    exit 1
fi

SIDECAR_CMD=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[1].command}')
EXPECTED_CMD='["/bin/sh","-c","tail -f /var/log/wordpress.log"]'
if [ "$SIDECAR_CMD" != "$EXPECTED_CMD" ]; then
    echo "Error: Sidecar container has an incorrect command."
    echo "Expected: $EXPECTED_CMD"
    echo "Found:    $SIDECAR_CMD"
    exit 1
fi

# 3. Check for a shared emptyDir volume
VOLUME_NAME=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.volumes[?(@.emptyDir)].name}')
if [ -z "$VOLUME_NAME" ]; then
    echo "Error: No shared emptyDir volume found in the Pod specification."
    exit 1
fi

# 4. Check for volume mounts in both containers
WP_MOUNT_PATH=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath="{.spec.template.spec.containers[0].volumeMounts[?(@.name=='$VOLUME_NAME')].mountPath}")
if [ "$WP_MOUNT_PATH" != "/var/log" ]; then
    echo "Error: The shared volume is not mounted at '/var/log' in the 'wordpress' container."
    exit 1
fi

SIDECAR_MOUNT_PATH=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath="{.spec.template.spec.containers[1].volumeMounts[?(@.name=='$VOLUME_NAME')].mountPath}")
if [ "$SIDECAR_MOUNT_PATH" != "/var/log" ]; then
    echo "Error: The shared volume is not mounted at '/var/log' in the 'sidecar' container."
    exit 1
fi

# 5. Check if the deployment is stable
kubectl wait --for=condition=available --timeout=60s deployment/$DEPLOYMENT -n $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Deployment '$DEPLOYMENT' did not become available after the update. Check its status and events."
    exit 1
fi

echo "done"
exit 0
