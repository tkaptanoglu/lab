#!/bin/bash
# atomic/install_vault.sh
# Purpose: Install HashiCorp Vault CLI on Ubuntu 22.04
# Idempotent and suitable for Golden Image automation

set -euo pipefail

echo "=== Installing Vault CLI ==="

# Prerequisites
sudo apt update
sudo apt install -y curl unzip gnupg lsb-release software-properties-common

# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Vault
sudo apt update
sudo apt install -y vault

# Verify installation
vault --version

echo "=== Vault installation complete ==="

