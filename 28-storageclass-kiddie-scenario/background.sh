#!/bin/bash

# Install the local-path-provisioner
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml

# Create a non-default StorageClass to ensure the user must explicitly change the default
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF

echo "Prerequisites are set up. The 'local-path' provisioner is available and a 'standard' StorageClass exists."
