#!/bin/bash
# composite/kubeadm_init_control_plane.sh
# Purpose: Initialize Kubernetes control plane and set up kubectl for the current user
# Assumes Kubernetes readiness steps have already been applied.

set -euo pipefail

echo "--- kubeadm init: Starting control plane initialization ---"

# If the control plane has already been initialized, /etc/kubernetes/admin.conf will exist.
if [ -f /etc/kubernetes/admin.conf ]; then
  echo "Control plane already initialized (/etc/kubernetes/admin.conf exists). Skipping kubeadm init."
else
  echo "--- kubeadm init: Initializing control plane (pod CIDR for Flannel) ---"
  ./srv_automation/imperative/shell/atomic/k8s/control-plane/kubeadm_init.sh
fi

echo "--- kubeadm init: Configuring kubectl for current user ---"
./srv_automation/imperative/shell/atomic/k8s/control-plane/configure_kubectl_for_user.sh

echo "--- kubeadm init: COMPLETE ---"

