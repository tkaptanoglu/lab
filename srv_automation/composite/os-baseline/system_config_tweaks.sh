#!/bin/bash
# composite/system_config_tweaks.sh
# Purpose: Minimal system-level tweaks for reliability and performance
# Scope: Golden Image ONLY (non-Kubernetes-specific)

set -euo pipefail

echo "=== Applying system configuration tweaks ==="

echo "--- Ensuring time sync ---"
./srv_automation/atomic/os/system/ensure_time_sync.sh

echo "--- Increasing file limits ---"
./srv_automation/atomic/os/system/increase_file_limits.sh

echo "--- Enabling persistent journald ---"
./srv_automation/atomic/os/system/enable_persistent_journald.sh

echo "=== System configuration tweaks complete ==="

