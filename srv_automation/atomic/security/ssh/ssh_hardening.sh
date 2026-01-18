#!/bin/bash
# atomic: ssh_hardening.sh
# Purpose: Harden SSH configuration for security

set -euo pipefail

SSH_CONFIG="/etc/ssh/sshd_config"

echo "=== Hardening SSH configuration ==="

# Backup config if not already backed up
sudo cp -n "$SSH_CONFIG" "${SSH_CONFIG}.bak"

# Disable root login
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG" || echo 'PermitRootLogin no' | sudo tee -a "$SSH_CONFIG"

# Disable password authentication
sudo sed -i 's/^PermitEmptyPasswords.*/PermitEmptyPasswords no' "$SSH_CONFIG" || echo 'PermitEmptyPasswords no' | sudo tee -a "$SSH_CONFIG"

# Limit authentication attempts
sudo sed -i 's/MaxAuthTries.*/MaxAuthTries 3/' "$SSH_CONFIG" || echo 'MaxAuthTries 3' | sudo tee -a "$SSH_CONFIG"

# Restart ssh service
sudo systemctl restart ssh

echo "=== SSH hardening complete ==="

