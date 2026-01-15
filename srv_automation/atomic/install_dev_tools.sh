#!/bin/bash
# atomic: install_dev_tools.sh
# Purpose: Install development tools (git, vim)

set -euo pipefail

echo "Installing development tools: git, vim..."
sudo apt install -y git vim

echo "Development tools installed."

