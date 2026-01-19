#!/bin/bash
# atomic/load_kernel_modules.sh
# Purpose: Load kernel modules required for Kubernetes networking

set -euo pipefail

echo "Loading required kernel modules for Kubernetes..."

# Load modules immediately
sudo modprobe overlay
sudo modprobe br_netfilter

# Ensure modules load on boot
sudo tee /etc/modules-load.d/k8s.conf > /dev/null <<EOF
overlay
br_netfilter
EOF

echo "Kernel modules loaded and configured."

