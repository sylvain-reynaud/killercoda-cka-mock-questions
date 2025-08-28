#!/bin/bash

# This script breaks a single-node kubeadm cluster to simulate a failed migration.

# --- Break Kube API Server ---
# Point the API server to a non-existent external etcd, simulating the old config.
# Also, comment out the local etcd TLS settings.
APISERVER_MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

if [ -f "$APISERVER_MANIFEST" ]; then
    # Change etcd servers to a fake external IP
    sed -i 's|--etcd-servers=.*|--etcd-servers=https://10.0.0.100:2379|' "$APISERVER_MANIFEST"
    
    # Comment out local etcd certs
    sed -i 's|--etcd-cafile.*|#--etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt|' "$APISERVER_MANIFEST"
    sed -i 's|--etcd-certfile.*|#--etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt|' "$APISERVER_MANIFEST"
    sed -i 's|--etcd-keyfile.*|#--etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key|' "$APISERVER_MANIFEST"
else
    echo "Could not find kube-apiserver manifest. Exiting."
    exit 1
fi

# --- Break Controller Manager ---
# Remove the kubeconfig file path, so it can't connect to the (down) API server.
CM_MANIFEST="/etc/kubernetes/manifests/kube-controller-manager.yaml"

if [ -f "$CM_MANIFEST" ]; then
    sed -i 's|--kubeconfig.*|#--kubeconfig=/etc/kubernetes/controller-manager.conf|' "$CM_MANIFEST"
else
    echo "Could not find kube-controller-manager manifest. Exiting."
    exit 1
fi

# --- Break Scheduler ---
# Remove the kubeconfig file path for the scheduler as well.
SCHEDULER_MANIFEST="/etc/kubernetes/manifests/kube-scheduler.yaml"

if [ -f "$SCHEDULER_MANIFEST" ]; then
    sed -i 's|--kubeconfig.*|#--kubeconfig=/etc/kubernetes/scheduler.conf|' "$SCHEDULER_MANIFEST"
else
    echo "Could not find kube-scheduler manifest. Exiting."
    exit 1
fi

# Restart kubelet to apply the broken manifests
# This will cause the control plane to fail and the node to become NotReady.
systemctl restart kubelet

# Give it a moment to break
sleep 15
