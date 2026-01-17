#!/bin/bash
# atomic: install_ssh_key_from_github
# Purpose: Download a public SSH key from GitHub and install it for a user

set -euo pipefail

# User to install keys for -- TODO: Make this a parameter
USER="komutanucantekme"
USER_HOME=$(eval echo "~$USER")
SSH_DIR="$USER_HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

echo "=== Installing SSH key for $USER from GitHub ==="

# Ensure .ssh directory exists
sudo mkdir -p "$SSH_DIR"
sudo chmod 700 "$SSH_DIR"
sudo chown "$USER":"$USER" "$SSH_DIR"

# Ensure authorized_keys exists
sudo touch "$AUTHORIZED_KEYS"
sudo chmod 600 "$AUTHORIZED_KEYS"
sudo chown "$USER":"$USER" "$AUTHORIZED_KEYS"

# Download the public key from GitHub
# GITHUB_USERNAME="$(vault kv get -field=github_username secret/identity)"
# GITHUB_KEY_URL="https://github.com/${GITHUB_USERNAME}.keys"
GITHUB_KEY_URL="https://github.com/tkaptanoglu.keys"

# Add each key to authorized_keys if not already present
curl -fsSL "$GITHUB_KEY_URL" | while read -r key; do
	grep -qxF "$key" "$AUTHORIZED_KEYS" || echo "$key" | sudo tee -a "$AUTHORIZED_KEYS" >/dev/null
done

echo "=== SSH key installed succesfully ==="

