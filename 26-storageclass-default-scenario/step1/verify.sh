#!/bin/bash

SC_NAME="low-latency"

# 1. Verify StorageClass exists
echo "Verifying StorageClass '$SC_NAME' exists..."
if ! kubectl get sc "$SC_NAME" > /dev/null 2>&1; then
    echo "Verification FAILED: StorageClass '$SC_NAME' not found."
    exit 1
fi
echo "OK: StorageClass '$SC_NAME' found."

# 2. Verify provisioner and volumeBindingMode
echo "Verifying provisioner and volumeBindingMode..."
PROVISIONER=$(kubectl get sc "$SC_NAME" -o jsonpath='{.provisioner}')
if [ "$PROVISIONER" != "rancher.io/local-path" ]; then
    echo "Verification FAILED: StorageClass '$SC_NAME' has incorrect provisioner. Expected 'rancher.io/local-path', got '$PROVISIONER'."
    exit 1
fi

BINDING_MODE=$(kubectl get sc "$SC_NAME" -o jsonpath='{.volumeBindingMode}')
if [ "$BINDING_MODE" != "WaitForFirstConsumer" ]; then
    echo "Verification FAILED: StorageClass '$SC_NAME' has incorrect volumeBindingMode. Expected 'WaitForFirstConsumer', got '$BINDING_MODE'."
    exit 1
fi
echo "OK: Provisioner and volumeBindingMode are correct."

# 3. Verify it is the default StorageClass
echo "Verifying '$SC_NAME' is the default StorageClass..."
IS_DEFAULT=$(kubectl get sc "$SC_NAME" -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')
if [ "$IS_DEFAULT" != "true" ]; then
    echo "Verification FAILED: StorageClass '$SC_NAME' is not set as the default."
    exit 1
fi
echo "OK: '$SC_NAME' is the default StorageClass."

# 4. Verify no other StorageClass is default
echo "Verifying no other StorageClass is default..."
DEFAULT_COUNT=$(kubectl get sc -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}' | wc -w)
if [ "$DEFAULT_COUNT" -ne 1 ]; then
    echo "Verification FAILED: Found $DEFAULT_COUNT default StorageClasses, but expected only 1 ('$SC_NAME')."
    exit 1
fi
echo "OK: Only one default StorageClass exists."

echo "done"
exit 0
