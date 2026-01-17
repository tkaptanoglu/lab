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

# Create Vault user and directories
sudo useradd --system --home /etc/vault.d --shell /bin/false vault
sudo mkdir -p /etc/vault.d /var/lib/vault/data
sudo chown -R vault:vault /etc/vault.d /var/lib/vault
sudo chmod 750 /var/lib/vault/data

# Create systemd service for Vault
sudo tee /etc/systemd/system/vault.service > /dev/null <<EOF
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Vault service
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault

echo "=== Vault installation complete ==="

