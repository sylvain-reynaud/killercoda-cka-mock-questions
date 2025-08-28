#!/bin/bash

# Add web.k8s.local to /etc/hosts to be resolved by curl
echo "127.0.0.1 web.k8s.local" >> /etc/hosts

# Create namespace
kubectl create ns nginx-static

# Create self-signed certificate for web.k8s.local
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt \
  -subj "/CN=web.k8s.local"

# Create TLS secret
kubectl create secret tls nginx-tls --key /tmp/tls.key --cert /tmp/tls.crt -n nginx-static

# Create NGINX configmap, deployment, service, and ingress
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: nginx-static
data:
  default.conf: |
    server {
        listen 80;
        listen 443 ssl;
        server_name web.k8s.local;

        ssl_certificate /etc/nginx/ssl/tls.crt;
        ssl_certificate_key /etc/nginx/ssl/tls.key;

        # Initial configuration allows TLSv1.2 and TLSv1.3
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-static
  namespace: nginx-static
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-static
  template:
    metadata:
      labels:
        app: nginx-static
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6
        ports:
        - containerPort: 80
        - containerPort: 443
        volumeMounts:
        - name: nginx-config-volume
          mountPath: /etc/nginx/conf.d
        - name: nginx-tls-volume
          mountPath: /etc/nginx/ssl
          readOnly: true
      volumes:
      - name: nginx-config-volume
        configMap:
          name: nginx-config
      - name: nginx-tls-volume
        secret:
          secretName: nginx-tls
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-static-service
  namespace: nginx-static
spec:
  selector:
    app: nginx-static
  ports:
    - name: https
      protocol: TCP
      port: 443
      targetPort: 443
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: nginx-static
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  tls:
  - hosts:
    - web.k8s.local
    secretName: nginx-tls
  rules:
  - host: web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-static-service
            port:
              name: https
EOF

# Wait for deployment to be ready
echo "Waiting for NGINX deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/nginx-static -n nginx-static
echo "NGINX deployment is ready."
