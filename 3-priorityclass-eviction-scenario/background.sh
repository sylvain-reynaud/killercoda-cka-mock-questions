#!/bin/bash

# Create the priority namespace
kubectl create namespace priority

# Create PriorityClasses: one very high, one low
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: super-high-priority
value: 1000000
globalDefault: false
description: "This is a high priority class for critical system services."
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 100
globalDefault: false
description: "This is a low priority class for non-essential services."
EOF

# Create the 'resource-hog' deployment with low priority
# It requests enough CPU to prevent other pods from scheduling easily
cat <<EOF | kubectl apply -n priority -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-hog
  labels:
    app: resource-hog
spec:
  replicas: 1
  selector:
    matchLabels:
      app: resource-hog
  template:
    metadata:
      labels:
        app: resource-hog
    spec:
      priorityClassName: low-priority
      containers:
      - name: stress
        image: polinux/stress
        args:
        - --cpu
        - "1"
        - --timeout
        - "600s"
        resources:
          requests:
            cpu: "800m"
EOF

# Create the 'busybox-logger' deployment without a priority class
# It requests enough CPU that it can't run while the resource-hog is running
cat <<EOF | kubectl apply -n priority -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-logger
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
        resources:
          requests:
            cpu: "300m"
EOF

# Wait for the low-priority pod to be running
kubectl wait --for=condition=available --timeout=300s deployment/resource-hog -n priority

# The busybox-logger pod will be pending due to insufficient resources
