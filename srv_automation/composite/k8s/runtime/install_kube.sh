#!/bin/bash
# composite/install_kube.sh
# Purpose: Install Kubernetes tools (kubeadm, kubelet, kubectl)

set -euo pipefail

echo "--- Kubernetes Tools: Adding Kubernetes APT repository ---"
./srv_automation/atomic/add_k8s_repo.sh

echo "--- Kubernetes Tools: Installing kubeadm, kubelet, and kubectl ---"
./srv_automation/atomic/install_kube_tools.sh

echo "--- Kubernetes Tools: Holding kubeadm, kubelet, and kubectl package versions ---"
./srv_automation/atomic/hold_kube_packages.sh

echo "--- Kubernetes Tools: COMPLETE ---"

