#!/bin/bash
# composite: generic_network_config.sh
# Purpose: Apply generic network configuration

set -euo pipefail

echo "=== Applying generic network configuration ==="

echo "--- Configuring hostname ---"
./srv_automation/atomic/configure_hostname.sh

echo "--- Configuring DNS ---"
./srv_automation/atomic/configure_dns.sh

echo "--- Applying generic sysctl network tuning"
./srv_automation/atomic/sysctl_generic_network_tuning.sh

echo "--- Ensuring network services are enabled"
./srv_automation/atomic/ensure_network_services_enabled.sh

echo "=== Generic network configuration complete"

