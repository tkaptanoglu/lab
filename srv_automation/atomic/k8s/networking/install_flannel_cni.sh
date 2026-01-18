#!/bin/bash
# atomic/install_flannel_cni.sh
# Purpose: Install Flannel CNI for Kubernetes

set -euo pipefail

echo "Installing Flannel CNI..."

FLANNEL_MANIFEST_URL="https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"

# Apply Flannel manifest
kubectl apply -f "$FLANNEL_MANIFEST_URL"

echo "Flannel CNI installation complete."

