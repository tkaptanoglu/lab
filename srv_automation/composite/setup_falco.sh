#!/bin/bash
# composite/install_and_configure_falco.sh
# Purpose: Install Falco and configure email alerting

set -euo pipefail

echo "=== Installing and configuring Falco ==="

./srv_automation/atomic/install_falco.sh
./srv_automation/atomic/setup_falco_emails.sh

echo "=== Falco installation and configuration complete ==="

