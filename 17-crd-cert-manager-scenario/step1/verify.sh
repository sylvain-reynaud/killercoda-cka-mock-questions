#!/bin/bash

RESOURCES_FILE=~/resources.yaml
SUBJECT_FILE=~/subject.yaml

# 1. Check for the resources.yaml file and its content
if [ ! -f "$RESOURCES_FILE" ]; then
    echo "Error: File '$RESOURCES_FILE' not found."
    exit 1
fi

# Check for some of the key cert-manager CRDs in the file
if ! grep -q "certificates.cert-manager.io" "$RESOURCES_FILE" || ! grep -q "issuers.cert-manager.io" "$RESOURCES_FILE" || ! grep -q "clusterissuers.cert-manager.io" "$RESOURCES_FILE"; then
    echo "Error: '$RESOURCES_FILE' does not seem to contain the list of cert-manager CRDs."
    exit 1
fi

# 2. Check for the subject.yaml file and its content
if [ ! -f "$SUBJECT_FILE" ]; then
    echo "Error: File '$SUBJECT_FILE' not found."
    exit 1
fi

# The description for the subject field starts with "X.509 Subject". We'll grep for a key part of it.
if ! grep -q "X.509 Subject" "$SUBJECT_FILE" || ! grep -q "organizationalUnit" "$SUBJECT_FILE"; then
    echo "Error: '$SUBJECT_FILE' does not seem to contain the correct documentation for the 'subject' field of the Certificate resource."
    exit 1
fi

echo "done"
exit 0
