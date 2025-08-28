#!/bin/bash

# Create the namespace
kubectl create namespace nodeport-expose

# Create the deployment without a containerPort defined
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodeport-deployment
  namespace: nodeport-expose
  labels:
    app: nodeport-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nodeport-app
  template:
    metadata:
      labels:
        app: nodeport-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6
        # Note: No ports are exposed here initially
EOF
