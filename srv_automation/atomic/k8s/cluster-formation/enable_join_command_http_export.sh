#!/bin/bash
# atomic/enable_join_command_http_export.sh
# Purpose: Optionally enable an HTTP service to download the join command from the LAN
# Opt-in via: EXPORT_JOIN_COMMAND_HTTP=true

set -euo pipefail

echo "Enabling HTTP export for join command (port 8022)..."

OUT_DIR="/var/lib/srv_automation/k8s"
SERVICE_FILE="/etc/systemd/system/srv-automation-join-export.service"

sudo mkdir -p "${OUT_DIR}"

sudo tee "${SERVICE_FILE}" > /dev/null <<EOF
[Unit]
Description=Serve Kubernetes join command for srv_automation (HTTP)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=${OUT_DIR}
ExecStart=/usr/bin/python3 -m http.server 8022 --bind 0.0.0.0
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now srv-automation-join-export.service

echo "HTTP export enabled."
echo "Fetch from another machine:"
echo "  curl -fsSL http://<master-ip>:8022/join-command.sh -o join-command.sh"
echo "  chmod +x join-command.sh && sudo ./join-command.sh"

