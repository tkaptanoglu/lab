#!/bin/bash
# atomic/increase_file_limits.sh
# Purpose: Increase file descriptor limits for reliability

set -euo pipefail

echo "Increasing file descriptor limits..."

LIMITS_FILE="/etc/security/limits.d/99-custom-nofile.conf"

sudo tee "$LIMITS_FILE" > /dev/null <<EOF
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF

echo "File descriptor limits configured."

