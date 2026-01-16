#!/bin/bash
# workflow: golden_image.sh
# Purpose: Build a Golden Image from a pristine Ubuntu setup

set -euo pipefail

# NOTE: If you wish to redefine what 'necessary package' means, please modify the relevant atomics.
echo "=== Step 1/4: Install necessary packages"
./srv_automation/composite/install_necessary_tools.sh

# Security baselines: Automated patching, VPN, firewall, SSH hardening
echo "=== Step 2/4: Apply security baselines"
./srv_automation/composite/apply_security_baselines.sh

# Generic network config: Hostname, DNS, generic sysctl tuning
echo "=== Step 3/4: Configure generic network"
./srv_automation/composite/generic_network_config.sh

# System configuration tweaks
echo "=== Step 4/4: System configuration tweaks"
./srv_automation/composite/system_config_tweaks.sh

echo "=== Golden Image creation complete. ==="

