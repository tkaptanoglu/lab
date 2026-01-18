#!/bin/bash
# atomic/kubeadm_init.sh
# Purpose: Initialize Kubernetes control plane (Flannel-compatible)

set -euo pipefail

echo "Running kubeadm init (control plane initialization)..."

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

echo "kubeadm init completed."

