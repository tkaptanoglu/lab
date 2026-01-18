#!/bin/bash
# atomic: install_network_tools.sh
# Purpose: Install network tools (iw, speedtest-cli, curl)

set -euo pipefail

echo "Installing network tools: iw, speedtest-cli, curl..."
sudo apt install -y iw speedtest-cli curl

echo "Network tools installed."

