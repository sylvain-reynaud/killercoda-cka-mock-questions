#!/bin/bash

KUBE_APISERVER_MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

# Wait for the manifest to be created
while [ ! -f $KUBE_APISERVER_MANIFEST ]; do
  echo "Waiting for $KUBE_APISERVER_MANIFEST to be created..."
  sleep 2
done

# Introduce the misconfiguration
echo "Introducing misconfiguration into $KUBE_APISERVER_MANIFEST..."
sed -i 's/--etcd-servers=https://127.0.0.1:2379/--etcd-servers=https://127.0.0.1:2380/g' $KUBE_APISERVER_MANIFEST

echo "The kube-apiserver is now misconfigured. The cluster will be in a broken state."
# Give the kubelet time to react to the change
sleep 15
