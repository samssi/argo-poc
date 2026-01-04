# 1. Create the folders
mkdir -p helm/apps/nginx-demo/templates

# 2. Create the Chart definition
cat <<EOF > helm/apps/nginx-demo/Chart.yaml
apiVersion: v2
name: nginx-demo
description: A simple Nginx for the demo
type: application
version: 1.0.0
appVersion: "1.25.0"
EOF

# 3. Create a basic Deployment and Service
cat <<EOF > helm/apps/nginx-demo/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-demo
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
EOF

# 4. Create an empty values file (to satisfy the ApplicationSet)
touch helm/apps/nginx-demo/values.yaml

# 5. Create environment setup for local arch linux
mkdir -p helm/environments/local-arch-linux/
cat <<EOF > helm/environments/local-arch-linux/nginx-demo.yaml
# Add env settings if required
EOF
