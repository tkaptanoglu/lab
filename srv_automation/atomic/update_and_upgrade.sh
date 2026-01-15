#!/bin/bash
# atomic: update_and_upgrade.sh
# Purpose: update package lists and upgrade all packages

set -euo pipefail  # Fail on errors, undefined vars, and errors in pipes

echo "Updating package lists..."
sudo apt update

echo "Upgrading packages..."
sudo apt upgrade -y

echo "Done updating and upgrading packages."

