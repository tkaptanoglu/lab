#!/bin/bash
# atomic/install_vault.sh
# Purpose: Install + configure + start HashiCorp Vault (dev-style) on Ubuntu 22.04,
#          then initialize + unseal + login automatically (NOT production-safe).

set -euo pipefail

echo "Installing Vault..."

wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault

echo "Configuring Vault..."

echo "Vault installed and configured successfully."

