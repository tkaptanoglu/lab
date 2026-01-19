#!/bin/bash
# atomic/setup_falco_email_notifications.sh
# Purpose: Send Falco alerts via email using Vault-stored identity.email

set -euo pipefail

echo "=== Configuring Falco email alerts ==="

# Preconditions
command -v vault >/dev/null 2>&1 || {
  echo "ERROR: vault CLI not found"
  exit 1
}

command -v mail >/dev/null 2>&1 || {
  echo "ERROR: mail command not found (install mailutils or msmtp)"
  exit 1
}

# Read email address from Vault
ALERT_EMAIL="$(vault kv get -field=email secret/identity)"

if [ -z "$ALERT_EMAIL" ]; then
  echo "ERROR: Vault returned empty email value"
  exit 1
fi

echo "Using alert email: $ALERT_EMAIL"

# Create mail forwarder
MAIL_FORWARDER="/usr/local/bin/falco_mail_forwarder.sh"

sudo tee "$MAIL_FORWARDER" > /dev/null <<EOF
#!/bin/bash
while read -r line; do
  echo "\$line" | mail -s "Falco Alert on \$(hostname)" "$ALERT_EMAIL"
done
EOF

sudo chmod +x "$MAIL_FORWARDER"

# Create systemd service
SERVICE_FILE="/etc/systemd/system/falco-email-alerts.service"

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Send Falco alerts via email
After=falco.service
Requires=falco.service

[Service]
ExecStart=/bin/bash -c "journalctl -fu falco | $MAIL_FORWARDER"
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable falco-email-alerts
sudo systemctl start falco-email-alerts

echo "=== Falco email alerting enabled ==="

