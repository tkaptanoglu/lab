#!/bin/bash
# composite/install_and_configure_falco.sh
# Purpose: Install Falco and configure email alerting

set -euo pipefail

echo "=== Installing and configuring Falco ==="

echo "--- Installing Falco ---"
./srv_automation/atomic/install_falco.sh

echo "--- Setting up Falco to send email notifications ---"
./srv_automation/atomic/setup_falco_email_notifications.sh

echo "=== Falco installation and configuration complete ==="

