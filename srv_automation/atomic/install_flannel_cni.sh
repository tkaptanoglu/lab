#!/bin/bash
# composite/install_flannel_cni.sh
# Purpose: Install Flannel CNI on the cluster

set -euo pipefail

echo "--- Flannel CNI: Installing ---"
./srv_automation/atomic/apply_flannel_manifest.sh

echo "--- Flannel CNI: COMPLETE ---"

