#!/bin/bash

NAMESPACE="sp-culator"

# Create the namespace
kubectl create namespace $NAMESPACE

# Create the deployment without a containerPort defined
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: front-end
  namespace: $NAMESPACE
  labels:
    app: front-end
spec:
  replicas: 1
  selector:
    matchLabels:
      app: front-end
  template:
    metadata:
      labels:
        app: front-end
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6
        # Note: No ports are exposed here initially
EOF
