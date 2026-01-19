#!/bin/bash
# atomic/configure_kubectl_for_user.sh
# Purpose: Configure kubectl access for the current user

set -euo pipefail

echo "Configuring kubectl for current user..."

KUBECONFIG_SRC="/etc/kubernetes/admin.conf"
KUBECONFIG_DEST="$HOME/.kube/config"

mkdir -p "$HOME/.kube"
sudo cp -f "$KUBECONFIG_SRC" "$KUBECONFIG_DEST"
sudo chown "$(id -u):$(id -g)" "$KUBECONFIG_DEST"

echo "kubectl configured for user $(whoami)."

