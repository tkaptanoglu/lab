#!/bin/bash
# atomic/apply_navidrome_service.sh
# Purpose: Apply Navidrome Service YAML, verify NodePort, and print Tailscale-accessible URL

set -euo pipefail

NAMESPACE="music"
SERVICE="navidrome"

echo "Applying Navidrome Service YAML..."

kubectl apply -n "${NAMESPACE}" -f ./manifests/navidrome/navidrome-service.yaml

echo "Verifying service '${SERVICE}' exists..."
kubectl -n "${NAMESPACE}" get svc "${SERVICE}" >/dev/null

SVC_TYPE="$(kubectl -n "${NAMESPACE}" get svc "${SERVICE}" -o jsonpath='{.spec.type}')"
if [ "${SVC_TYPE}" != "NodePort" ]; then
  echo "ERROR: Service type is '${SVC_TYPE}', expected 'NodePort' for simple Tailscale access."
  echo "Fix k8s/navidrome-service.yaml to use: spec.type: NodePort"
  exit 1
fi

NODE_PORT="$(kubectl -n "${NAMESPACE}" get svc "${SERVICE}" -o jsonpath='{.spec.ports[0].nodePort}')"
if [ -z "${NODE_PORT}" ]; then
  echo "ERROR: Could not determine nodePort for service '${SERVICE}'."
  kubectl -n "${NAMESPACE}" describe svc "${SERVICE}" || true
  exit 1
fi

TAILSCALE_IP="$(ip -o -4 addr show dev tailscale0 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1 || true)"
if [ -z "${TAILSCALE_IP}" ]; then
  echo "WARNING: Could not detect tailscale0 IPv4 on this node."
  echo "Service is NodePort ${NODE_PORT}. Access it via this node's reachable IP:"
  echo "  http://<node-ip>:${NODE_PORT}"
else
  echo "Navidrome should be reachable over Tailscale at:"
  echo "  http://${TAILSCALE_IP}:${NODE_PORT}"
fi

echo "Navidrome Service applied and verified."

