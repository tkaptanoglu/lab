# falco role (Ubuntu 22.04 ARM64 / Raspberry Pi)

Installs Falco from the official Falco DEB repository.

Defaults:
- noninteractive install (no dialog)
- modern_ebpf driver choice

Variables:
- falco_driver_choice: modern_ebpf | ebpf | kmod | none
- falco_install_build_deps: true/false (only useful for kmod/ebpf)
- falcoctl_enabled: "no" to disable automatic rules updates

