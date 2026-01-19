#!/bin/bash
# atomic: install_security_tools.sh
# Purpose: Install security / certificate tools (ca-certificates, apt-transport-https, gpg)

set -euo pipefail

echo "Installing security tools: ca-certificates, apt-transport-https, gpg..."
sudo apt install -y ca-certificates apt-transport-https gpg

echo "Security tools installed."

