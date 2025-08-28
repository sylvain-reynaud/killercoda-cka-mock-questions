#!/bin/bash

echo "Setting up CKA exam environment..."

# Wait for Kubernetes cluster to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Create autoscale namespace
kubectl create namespace autoscale

# Create apache-deployment with resource requests (required for HPA)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deployment
  namespace: autoscale
  labels:
    app: apache
spec:
  replicas: 2
  selector:
    matchLabels:
      app: apache
  template:
    metadata:
      labels:
        app: apache
    spec:
      containers:
      - name: apache
        image: httpd:2.4-alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: apache-service
  namespace: autoscale
spec:
  selector:
    app: apache
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Install metrics-server (required for HPA CPU metrics)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Patch metrics-server for Killercoda environment
kubectl patch deployment metrics-server -n kube-system --type='merge' -p='{"spec":{"template":{"spec":{"containers":[{"name":"metrics-server","args":["--cert-dir=/tmp","--secure-port=4443","--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname","--kubelet-use-node-status-port","--metric-resolution=15s","--kubelet-insecure-tls"]}]}}}}'

# Wait for metrics-server to be ready
kubectl wait --for=condition=Available deployment/metrics-server -n kube-system --timeout=300s

# Wait for apache deployment to be ready
kubectl wait --for=condition=Available deployment/apache-deployment -n autoscale --timeout=300s

# Verify environment is ready
kubectl get pods -n autoscale
kubectl get deployment apache-deployment -n autoscale

echo "✅ Environment ready: apache-deployment running in autoscale namespace"
echo "✅ Metrics server installed and running"
echo "Ready for CKA exam question!"

# Create completion marker
touch /tmp/setup-complete