#!/bin/bash
# atomic/install_kube_tools.sh
# Purpose: Install kubeadm, kubelet, and kubectl

set -euo pipefail

echo "Installing kubeadm, kubelet, and kubectl..."

sudo apt install -y kubelet kubeadm kubectl

# Ensure kubelet starts on boot
sudo systemctl enable kubelet

echo "Kubernetes tools installed."

