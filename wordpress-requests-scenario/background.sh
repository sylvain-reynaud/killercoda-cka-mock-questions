#!/bin/bash

# Create a namespace for the wordpress installation
kubectl create namespace relative-fawn

# Create MySQL password secret
kubectl create secret generic mysql-pass --from-literal=password=my-secret-pw -n relative-fawn

# Create MySQL deployment and service
cat <<EOF | kubectl apply -n relative-fawn -f -
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 3306
          name: mysql
EOF

# Create WordPress deployment and service
cat <<EOF | kubectl apply -n relative-fawn -f -
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: frontend
  replicas: 3
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      initContainers:
      - name: wait-for-mysql
        image: busybox:1.28
        command: ['sh', '-c', 'until nslookup wordpress-mysql; do echo waiting for mysql; sleep 2; done;']
      containers:
      - image: wordpress:4.8-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: wordpress-mysql
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 80
          name: wordpress
EOF

# Wait for deployments to be ready
kubectl wait --for=condition=available --timeout=600s deployment/wordpress-mysql -n relative-fawn
kubectl wait --for=condition=available --timeout=600s deployment/wordpress -n relative-fawn
