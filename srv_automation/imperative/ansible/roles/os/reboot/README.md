# reboot role

Reboots the system using Ansible's reboot module.

This should be the final role/task in a workflow, as it interrupts execution.
Disable reboot by setting `reboot_enabled: false`.

