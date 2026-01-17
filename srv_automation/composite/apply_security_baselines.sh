#!/bin/bash
# composite: apply_security_baselines.sh
# Purpose: Apply security baselines to the system
# This composite calls atomices for patching, VPN, firewall, and SSH hardening

set -euo pipefail

echo "=== Applying security baselines ==="

echo "--- Automated patching ---"
./srv_automation/atomic/automated_patching.sh

echo "--- Firewall setup (skipping) ---"
# ./srv_automation/atomic/configure_firewall.sh

echo "--- SSH hardening ---"
./srv_automation/atomic/ssh_hardening.sh

echo "--- Install and configure Falco (skipping) ---"
# ./srv_automation/composite/setup_falco.sh

echo "=== Security baselines applied successfully. ==="

