#!/bin/bash
# workflow/kubernetes_readiness.sh
# Purpose: Prepare an Ubuntu 22.04 server for Kubernetes

set -euo pipefail

echo "--- Kubernetes Readiness Workflow: START ---"


# START: PREREQUISITES
echo "--- Step 1/4: Disabling swap ---"
./srv_automation/imperative/shell/atomic/k8s/prerequisites/swapoff.sh

echo "--- Step 2/4: Configuring kernel modules and sysctl settings for Kubernetes ---"
./srv_automation/imperative/shell/composite/k8s/prerequisites/k8s_prerequisites.sh

echo "--- Step 3/4: Installing and configuring containerd ---"
./srv_automation/imperative/shell/composite/k8s/prerequisites/setup_containerd.sh
# END: PREREQUISITES


# START: RUNTIME
echo "--- Step 4/4: Installing kubeadm, kubelet, and kubectl ---"
./srv_automation/imperative/shell/composite/k8s/runtime/install_kube.sh
# END: RUNTIME


echo "=== Kubernetes Readiness Workflow: COMPLETE ==="

