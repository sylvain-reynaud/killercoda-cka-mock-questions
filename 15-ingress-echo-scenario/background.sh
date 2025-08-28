#!/bin/bash

NAMESPACE="echo-sound"

# Create the namespace
kubectl create namespace $NAMESPACE

# Create the echoserver deployment and service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echoserver
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echoserver
  template:
    metadata:
      labels:
        app: echoserver
    spec:
      containers:
      - name: echoserver
        image: k8s.gcr.io/echoserver:1.10
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: echoserver-service
  namespace: $NAMESPACE
spec:
  selector:
    app: echoserver
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
EOF
