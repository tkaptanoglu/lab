#!/bin/bash
# atomic/install_vault.sh
# Purpose: Install + configure + start HashiCorp Vault (dev-style) on Ubuntu 22.04,
#          then initialize + unseal + login automatically (NOT production-safe).
#
# Notes:
# - Uses file storage at /var/lib/vault/data
# - Listens on 127.0.0.1:8200 with TLS disabled
# - Writes init credentials to /root/vault-init.txt (root-only)
#
# Idempotency:
# - Safe to re-run: won't re-init if already initialized, won't re-unseal if already unsealed.

set -euo pipefail

export VAULT_ADDR="http://127.0.0.1:8200"

echo "=== Installing Vault (server + CLI) ==="

# Prerequisites
sudo apt-get update
sudo apt-get install -y curl unzip gnupg lsb-release software-properties-common

# Add HashiCorp GPG key (idempotent)
if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
fi

# Add repository (idempotent)
HASHICORP_LIST=/etc/apt/sources.list.d/hashicorp.list
CODENAME="$(lsb_release -cs)"
REPO_LINE="deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${CODENAME} main"
if [ ! -f "${HASHICORP_LIST}" ] || ! grep -Fq "${REPO_LINE}" "${HASHICORP_LIST}"; then
  echo "${REPO_LINE}" | sudo tee "${HASHICORP_LIST}" >/dev/null
fi

# Install Vault
sudo apt-get update
sudo apt-get install -y vault

echo "Vault installed: $(command -v vault)"
vault --version

# Create Vault user and directories (idempotent)
if ! id -u vault >/dev/null 2>&1; then
  sudo useradd --system --home /etc/vault.d --shell /bin/false vault
fi

sudo mkdir -p /etc/vault.d /var/lib/vault/data

# Permissions
sudo chown -R vault:vault /etc/vault.d /var/lib/vault
sudo chmod 750 /var/lib/vault
sudo chmod 750 /var/lib/vault/data

# Create Vault server config
sudo tee /etc/vault.d/vault.hcl >/dev/null <<'EOF'
storage "file" {
  path = "/var/lib/vault/data"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}

ui = true

# Dev/VM-friendly: avoids mlock failures in many environments
disable_mlock = true
EOF

sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl

# Create/Update systemd service for Vault
sudo tee /etc/systemd/system/vault.service >/dev/null <<'EOF'
[Unit]
Description=HashiCorp Vault - A tool for managing secrets
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
LimitNOFILE=65536
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Vault service
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl restart vault

# Wait until Vault responds (but might be sealed/uninitialized)
echo "=== Waiting for Vault HTTP listener on 127.0.0.1:8200 ==="
for i in $(seq 1 60); do
  if curl -fsS "${VAULT_ADDR}/v1/sys/health" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Helper: get a field from `vault status` output
vault_status_field() {
  # Example line: "Initialized     true"
  vault status 2>/dev/null | awk -v key="$1" '$1 == key {print $2}'
}

echo "=== Checking Vault status ==="
INITIALIZED="$(vault_status_field Initialized || true)"
SEALED="$(vault_status_field Sealed || true)"

# Initialize if needed
# We use a single unseal key (shares=1 threshold=1) to match "fully automated dev setup".
# This is NOT how you'd run prod Vault.
if [ "${INITIALIZED:-false}" != "true" ]; then
  echo "=== Vault not initialized. Initializing... ==="

  # Create root-only file for init credentials
  # Avoid printing secrets to console.
  sudo bash -c 'umask 077; : > /root/vault-init.txt'

  # Run init and capture output in a root-only file
  sudo bash -c 'umask 077; vault operator init -key-shares=1 -key-threshold=1 > /root/vault-init.txt'

  # Re-check status
  INITIALIZED="true"
  SEALED="$(vault_status_field Sealed || true)"
else
  echo "=== Vault already initialized. ==="
fi

# Extract unseal key + root token from /root/vault-init.txt
# If Vault was initialized earlier, that file might not exist; we only use it when needed.
UNSEAL_KEY=""
ROOT_TOKEN=""

if sudo test -f /root/vault-init.txt; then
  UNSEAL_KEY="$(sudo awk -F': ' '/^Unseal Key 1: / {print $2}' /root/vault-init.txt | head -n1 || true)"
  ROOT_TOKEN="$(sudo awk -F': ' '/^Initial Root Token: / {print $2}' /root/vault-init.txt | head -n1 || true)"
fi

# Unseal if needed
SEALED="$(vault_status_field Sealed || true)"
if [ "${SEALED:-true}" = "true" ]; then
  echo "=== Vault is sealed. Unsealing... ==="
  if [ -z "${UNSEAL_KEY}" ]; then
    echo "ERROR: Vault is sealed but /root/vault-init.txt is missing or doesn't contain Unseal Key 1."
    echo "       You must unseal manually (or restore the unseal key)."
    exit 1
  fi
  vault operator unseal "${UNSEAL_KEY}" >/dev/null
else
  echo "=== Vault already unsealed. ==="
fi

# Login (for subsequent commands in this script)
echo "=== Logging in to Vault ==="
if [ -z "${ROOT_TOKEN}" ]; then
  echo "ERROR: Root token not found (expected in /root/vault-init.txt)."
  echo "       Login manually with a valid token."
  exit 1
fi
vault login -no-print "${ROOT_TOKEN}" >/dev/null

# Enable KV v2 at secret/ (idempotent)
echo "=== Enabling KV v2 at secret/ (if needed) ==="
if ! vault secrets list -format=json | grep -q '"secret/":'; then
  vault secrets enable -path=secret kv-v2 >/dev/null
fi

echo "=== Vault is up, initialized, unsealed, and logged in ==="
echo "VAULT_ADDR is ${VAULT_ADDR}"
echo "Init credentials stored at: /root/vault-init.txt (root-only)"
echo
echo "Quick test (as your user, same shell):"
echo "  export VAULT_ADDR='${VAULT_ADDR}'"
echo "  vault kv put secret/hello value=world"
echo "  vault kv get secret/hello"

