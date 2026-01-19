#!/bin/bash
# atomic/hold_kube_packages.sh
# Purpose: Hold Kubernetes packages at current version to prevent unintended upgrades

set -euo pipefail

echo "Holding Kubernetes package versions..."

sudo apt-mark hold kubelet kubeadm kubectl

echo "Kubernetes packages are now held."

