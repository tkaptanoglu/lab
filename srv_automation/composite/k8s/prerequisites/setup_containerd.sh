#!/bin/bash
# composite/setup_containerd.sh
# Purpose: Install and configure containerd for Kubernetes

set -euo pipefail

echo "--- containerd: Installing ---"
./srv_automation/atomic/k8s/runtime/install_containerd.sh

echo "--- containerd: Configuring (SystemdCgroup=true) and enabling service ---"
./srv_automation/atomic/k8s/runtime/configure_containerd.sh

echo "--- containerd: COMPLETE ---"

