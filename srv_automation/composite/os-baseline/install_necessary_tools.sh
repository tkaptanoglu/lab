#!/bin/bash
# composite: install_necessary_tools.sh
# Purpose: Install all fundamental packages by calling relevant atomics

set -euo pipefail

echo "=== Starting installation of necessary tools ==="

echo "--- Step 1: Development tools ---"
./srv_automation/atomic/install_dev_tools.sh

echo "--- Step 2: Network tools ---"
./srv_automation/atomic/install_network_tools.sh

echo "--- Step 3: Security tools ---"
./srv_automation/atomic/install_security_tools.sh

echo "--- Step 4: Installing and logging in to VPN of choice ---"
./srv_automation/atomic/install_vpn.sh

echo "=== Finished installation of necessary tools ==="

