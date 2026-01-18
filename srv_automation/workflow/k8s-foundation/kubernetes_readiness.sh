#!/bin/bash
# workflow/kubernetes_readiness.sh
# Purpose: Prepare an Ubuntu 22.04 server for Kubernetes

set -euo pipefail

echo "--- Kubernetes Readiness Workflow: START ---"

echo "--- Step 1/4: Disabling swap ---"
./srv_automation/atomic/swapoff.sh

echo "--- Step 2/4: Configuring kernel modules and sysctl settings for Kubernetes ---"
./srv_automation/composite/k8s_prerequisites.sh

echo "--- Step 3/4: Installing and configuring containerd ---"
./srv_automation/composite/install_containerd.sh

echo "--- Step 4/4: Installing kubeadm, kubelet, and kubectl ---"
./srv_automation/composite/install_kube.sh

echo "=== Kubernetes Readiness Workflow: COMPLETE ==="

