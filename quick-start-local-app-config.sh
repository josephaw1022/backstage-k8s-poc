#!/bin/bash
set -euo pipefail

SECRET_NAME="backstage-reader-token"
SECRET_NS="kube-system"
CONFIG_FILE="app-config.local.yaml"
CLUSTER_NAME="backstage-demo"
CLUSTER_API=$(kubectl cluster-info --context kind-$CLUSTER_NAME| grep 'Kubernetes control plane' | awk '{print $NF}')
TOKEN=$(kubectl get secret "$SECRET_NAME" -n "$SECRET_NS" -o jsonpath='{.data.token}' | base64 -d)

echo "Writing updated $CONFIG_FILE..."

cat > "$CONFIG_FILE" <<EOF
# Backstage override configuration for your local development environment

kubernetes:
  frontend:
    podDelete:
      enabled: true

  serviceLocatorMethod:
    type: 'multiTenant'

  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - name: $CLUSTER_NAME
          url: $CLUSTER_API
          authProvider: serviceAccount
          serviceAccountToken: $TOKEN
          skipTLSVerify: true
          skipMetricsLookup: true

app:
  extensions:
    - entity-content:kubernetes/kubernetes

catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, System, API, Resource, Location]
  locations:
    - type: file
      target: ../../examples/entities.yaml
    - type: file
      target: ../../examples/template/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../examples/org.yaml
      rules:
        - allow: [User, Group]
EOF

echo "✅ $CONFIG_FILE written."
