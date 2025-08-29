#!/bin/bash

# Create the mariadb namespace
kubectl create namespace mariadb

# Create the PersistentVolume to simulate an existing, retained volume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv-orphaned
spec:
  capacity:
    storage: 500Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: "/mnt/data/mariadb"
EOF
