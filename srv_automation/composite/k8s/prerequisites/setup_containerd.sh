#!/bin/bash
# composite/setup_containerd.sh
# Purpose: Install and configure containerd for Kubernetes

set -euo pipefail

echo "--- containerd: Installing ---"
./srv_automation/atomic/install_containerd.sh

echo "--- containerd: Configuring (SystemdCgroup=true) and enabling service ---"
./srv_automation/atomic/configure_containerd.sh

echo "--- containerd: COMPLETE ---"

