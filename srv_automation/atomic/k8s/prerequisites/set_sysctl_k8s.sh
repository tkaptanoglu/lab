#!/bin/bash
# atomic/set_sysctl_k8s.sh
# Purpose: Apply sysctl settings required for Kubernetes networking

set -euo pipefail

echo "Applying sysctl settings for Kubernetes..."

sudo tee /etc/sysctl.d/k8s.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# Apply changes immediately
sudo sysctl --system

echo "Sysctl settings applied."

