#!/bin/bash
# atomic: enable_cgroups.sh
# Purpose: Enable cgroups (cpuset and memory) on Raspberry Pi and reboot

set -euo pipefail

echo "Enabling cgroups: cpuset and memory..."
sudo sed -i 's/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1/' /boot/firmware/cmdline.txt

echo "Cgroups enabled."

