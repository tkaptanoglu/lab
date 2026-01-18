#!/bin/bash
# atomic/apply_navidrome_deployment.sh
# Purpose: Apply Navidrome Deployment YAML and verify rollout

set -euo pipefail

NAMESPACE="music"
DEPLOYMENT="navidrome"

echo "Applying Navidrome Deployment YAML..."

kubectl apply -n "${NAMESPACE}" -f ./manifests/navidrome/navidrome-deployment.yaml

echo "Waiting for deployment rollout to complete..."
kubectl -n "${NAMESPACE}" rollout status deployment/"${DEPLOYMENT}" --timeout=180s

echo "Navidrome deployment status:"
kubectl -n "${NAMESPACE}" get deployment "${DEPLOYMENT}"
kubectl -n "${NAMESPACE}" get pods -l app=navidrome -o wide

echo "Navidrome Deployment applied and verified."

