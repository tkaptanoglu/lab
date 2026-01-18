#!/bin/bash
# atomic/configure_containerd.sh
# Purpose: Configure containerd for Kubernetes (systemd cgroups)

set -euo pipefail

echo "Configuring containerd for Kubernetes..."

# Ensure config directory exists
sudo mkdir -p /etc/containerd

# Generate default config if not present
if [ ! -f /etc/containerd/config.toml ]; then
    sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
fi

# Ensure SystemdCgroup is set to true
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Enable and restart containerd
sudo systemctl enable containerd
sudo systemctl restart containerd

# Informational version output
containerd --version || true

echo "containerd configured and running."

