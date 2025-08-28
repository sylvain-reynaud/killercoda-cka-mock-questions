#!/bin/bash

NAMESPACE="gateway-migration"

# Create the namespace
kubectl create namespace $NAMESPACE

# 1. Create Gateway API CRDs (if not present) and GatewayClass
# In a real scenario, a controller would be installed. Here, we just create the class.
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx-class
spec:
  controllerName: "example.com/gateway-controller"
EOF

# 2. Create a TLS Secret
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=gateway.web.k8s.local"
kubectl create secret tls web-tls --key /tmp/tls.key --cert /tmp/tls.crt -n $NAMESPACE

# 3. Create the web application deployment and service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: $NAMESPACE
spec:
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

# 4. Create the initial Ingress resource to be migrated
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: $NAMESPACE
spec:
  tls:
  - hosts:
    - gateway.web.k8s.local
    secretName: web-tls
  rules:
  - host: gateway.web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
EOF
