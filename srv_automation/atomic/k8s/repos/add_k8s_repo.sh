#!/bin/bash
# atomic/add_k8s_repo.sh
# Purpose: Add the Kubernetes APT repository

set -euo pipefail

echo "Adding Kubernetes APT repository..."

# Ensure required packages exist
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg

# Create keyring directory if missing
sudo mkdir -p /etc/apt/keyrings

# Download and install Kubernetes repo key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add apt source list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

sudo apt update

echo "Kubernetes APT repository added."

