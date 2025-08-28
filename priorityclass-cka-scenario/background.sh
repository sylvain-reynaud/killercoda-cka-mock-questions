#!/bin/bash

# Create the priority namespace
kubectl create namespace priority

# Create a high-value PriorityClass
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: super-high-priority
value: 1000000
globalDefault: false
description: "This is a high priority class for critical services."
EOF

# Create the busybox-logger deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-logger
  namespace: priority
  labels:
    app: busybox-logger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox-logger
  template:
    metadata:
      labels:
        app: busybox-logger
    spec:
      containers:
      - name: busybox
        image: busybox
        args:
        - /bin/sh
        - -c
        - 'while true; do echo "Logging from busybox"; sleep 10; done'
EOF
