#!/bin/bash

# Create and label namespaces
kubectl create namespace frontend
kubectl create namespace backend
kubectl label namespace frontend name=frontend
kubectl label namespace backend name=backend

# Create Frontend Deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: busybox
        image: busybox:stable
        command: ["sleep", "3600"]
EOF

# Create Backend Deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6
        ports:
        - containerPort: 80
EOF

# Apply a default deny-all ingress policy to the backend
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

# Create the directory and copy policy files for the user
mkdir -p /root/netpol
cp /tmp/assets/netpol/*.yaml /root/netpol/
