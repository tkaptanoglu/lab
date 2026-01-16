#!/bin/bash
# composite: apply_security_baselines.sh
# Purpose: Apply security baselines to the system
# This composite calls atomices for patching, VPN, firewall, and SSH hardening

set -euo pipefail

echo "=== Applying security baselines ==="

echo "--- Automated patching ---"
./srv_automation/atomic/automated_patching.sh

echo "--- VPN Setup (NOTE: Human involvement is required!) ---"
./srv_automation/atomic/install_vpn.sh

echo "--- Firewall setup ---"
./srv_automation/composite/configure_firewall.sh

echo "--- SSH hardening ---"
./srv_automation/composite/ssh_hardening.sh

echo "=== Security baselines applied successfully. ==="

