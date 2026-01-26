#!/bin/bash
# workflow: golden_image.sh
# Purpose: Build a Golden Image from a pristine Ubuntu setup

set -euo pipefail

echo "=== Golden Image creation started ==="


# START: OS BASELINE
# System configuration tweaks
# NOTE: If you wish to redefine what 'necessary package' means, please modify the relevant atomics.
echo "--- Step 1/4: Install necessary packages ---"
./srv_automation/imperative/shell/composite/os-baseline/install_necessary_tools.sh

echo "--- Step 2/4: System configuration tweaks ---"
./srv_automation/imperative/shell/composite/os-baseline/system_config_tweaks.sh
# END: OS BASELINE


# START: SECURITY
# Security baselines: Automated patching, VPN, firewall, SSH hardening
echo "--- Step 3/4: Apply security baselines ---"
./srv_automation/imperative/shell/composite/security/apply_security_baselines.sh
# END: SECURITY


# START: NETWORKING
# Generic network config: Hostname, DNS, generic sysctl tuning
echo "--- Step 4/4: Configure generic network (skipping) ---"
# ./srv_automation/imperative/shell/composite/networking/generic_network_config.sh
# END: NETWORKING


echo "=== Golden Image creation complete. ==="

