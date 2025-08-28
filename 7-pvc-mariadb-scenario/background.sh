#!/bin/bash

# Create the mariadb namespace
kubectl create namespace mariadb

# Create the PersistentVolume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
spec:
  capacity:
    storage: 500Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: "/mnt/data"
EOF

# Create the deployment manifest file for the user to edit
cat <<EOF > /root/maria.deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: maria-deployment
  namespace: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.5
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "supersecret"
        ports:
        - containerPort: 3306
EOF
