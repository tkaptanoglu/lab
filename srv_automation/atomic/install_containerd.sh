#!/bin/bash
# atomic/install_containerd.sh
# Purpose: Install containerd runtime

set -euo pipefail

echo "Installing containerd..."

# Install containerd from Ubuntu repos
sudo apt update
sudo apt install -y containerd

echo "containerd installed."

