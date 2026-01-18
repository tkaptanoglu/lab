#!/bin/bash
# composite/install_kube.sh
# Purpose: Install Kubernetes tools (kubeadm, kubelet, kubectl)

set -euo pipefail

echo "--- Kubernetes Tools: Adding Kubernetes APT repository ---"
./srv_automation/atomic/k8s/repos/add_k8s_repo.sh

echo "--- Kubernetes Tools: Installing kubeadm, kubelet, and kubectl ---"
./srv_automation/atomic/k8s/runtime/install_kube_tools.sh

echo "--- Kubernetes Tools: Holding kubeadm, kubelet, and kubectl package versions ---"
./srv_automation/atomic/k8s/runtime/hold_kube_packages.sh

echo "--- Kubernetes Tools: COMPLETE ---"

