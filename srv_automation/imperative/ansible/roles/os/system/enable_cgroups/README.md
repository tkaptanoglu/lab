# enable_cgroups role

Enables Raspberry Pi cgroups (cpuset + memory) by ensuring these kernel cmdline options exist:
- cgroup_enable=cpuset
- cgroup_enable=memory
- cgroup_memory=1

Edits: /boot/firmware/cmdline.txt (Ubuntu/RPi layout)

Reboots by default when changes are made. Disable reboot by setting:
enable_cgroups_reboot: false

