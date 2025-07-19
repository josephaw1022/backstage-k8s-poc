#!/bin/bash
set -euo pipefail

CLUSTER_NAME="backstage-demo"
SERVICE_ACCOUNT_NAME="backstage-reader"
SERVICE_ACCOUNT_NS="kube-system"
SECRET_NAME="backstage-reader-token"
NAMESPACES=("example-website" "example-website-2" "example-website-3" "example-website-4")

echo "Creating kind cluster: $CLUSTER_NAME"
kind create cluster --name "$CLUSTER_NAME"

echo "Creating service account in $SERVICE_ACCOUNT_NS"
kubectl create serviceaccount "$SERVICE_ACCOUNT_NAME" -n "$SERVICE_ACCOUNT_NS"

echo "Creating cluster-admin binding"
kubectl create clusterrolebinding "${SERVICE_ACCOUNT_NAME}-binding" \
  --clusterrole=cluster-admin \
  --serviceaccount="${SERVICE_ACCOUNT_NS}:${SERVICE_ACCOUNT_NAME}"

echo "Creating token secret with annotation"
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${SECRET_NAME}
  namespace: ${SERVICE_ACCOUNT_NS}
  annotations:
    kubernetes.io/service-account.name: ${SERVICE_ACCOUNT_NAME}
type: kubernetes.io/service-account-token
EOF

for ns in "${NAMESPACES[@]}"; do
  echo "Creating namespace: $ns"
  kubectl create namespace "$ns"

  echo "Labeling namespace"
  kubectl label namespace "$ns" \
    app=example-website \
    backstage.io/kubernetes-id=example-website

  echo "Deploying nginx to $ns"
  kubectl apply -n "$ns" -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-website
  labels:
    app: example-website
    backstage.io/kubernetes-id: example-website
spec:
  replicas: 5
  selector:
    matchLabels:
      app: example-website
  template:
    metadata:
      labels:
        app: example-website
        backstage.io/kubernetes-id: example-website
    spec:
      serviceAccountName: ${SERVICE_ACCOUNT_NAME}
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: example-website
  labels:
    app: example-website
    backstage.io/kubernetes-id: example-website
spec:
  selector:
    app: example-website
  ports:
    - port: 80
      targetPort: 80
EOF
done

echo "✅ All done. Service account is cluster-admin and deployments are complete."
