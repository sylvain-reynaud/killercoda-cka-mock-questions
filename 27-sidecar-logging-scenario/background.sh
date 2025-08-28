#!/bin/bash

# Create the deployment that simulates a legacy application writing to a file
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synergy-deployment
  labels:
    app: synergy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synergy
  template:
    metadata:
      labels:
        app: synergy
    spec:
      containers:
      - name: synergy-app
        image: busybox:stable
        command: ["/bin/sh", "-c"]
        args:
        - |
          mkdir -p /var/log;
          while true; do
            echo "Logging data at $(date)" >> /var/log/synergy-deployment.log;
            sleep 5;
          done
EOF

kubectl wait --for=condition=available deployment/synergy-deployment --timeout=120s

echo "The 'synergy-deployment' is running."
