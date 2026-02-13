#!/usr/bin/env bash
set -euo pipefail

# Purpose:
# Produce an LLM-friendly snapshot of the last 24h of system health, config, and performance signals.
# Focus: inefficiencies, anti-patterns, misconfigurations, optimization opportunities.

MOUNT_POINT="${MOUNT_POINT:-/mnt/external}"
LOG_DIR="${LOG_DIR:-$MOUNT_POINT/srv_logs}"
HOURS="${HOURS:-24}"

HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname)"
TS="$(date '+%Y-%m-%d %H-%M-%S')"
OUTFILE="${LOG_DIR}/${TS} ${HOSTNAME_SHORT} srv logs.txt"

if ! mountpoint -q "$MOUNT_POINT"; then
  echo "ERROR: $MOUNT_POINT is not a mountpoint; refusing to write logs there." >&2
  exit 2
fi

mkdir -p "$LOG_DIR"

# Helpers
section() {
  echo
  echo "================================================================================"
  echo "## $1"
  echo "================================================================================"
}
run() {
  # run "Title" cmd...
  local title="$1"; shift
  echo
  echo "### $title"
  echo "\$ $*"
  # shellcheck disable=SC2068
  "$@" 2>&1 || echo "(command failed: $?)"
}

# journalctl filters: for LLM use, warnings/errors are usually the best signal-to-noise.
J_SINCE="${HOURS} hours ago"

{
  section "Context"
  echo "timestamp_iso: $(date -Is)"
  echo "hostname: ${HOSTNAME_SHORT}"
  echo "fqdn: $(hostname -f 2>/dev/null || true)"
  echo "uptime: $(uptime -p 2>/dev/null || true)"
  echo "kernel: $(uname -r)"
  echo "os_release:"
  (cat /etc/os-release 2>/dev/null || true) | sed 's/^/  /'
  echo "cmdline:"
  (cat /proc/cmdline 2>/dev/null || true) | sed 's/^/  /'

  section "Hardware / Topology (helps identify bottlenecks)"
  run "CPU and RAM summary" bash -lc 'lscpu || true; echo; free -h || true'
  run "Load and processes snapshot" bash -lc 'uptime; ps -eo pid,ppid,comm,%cpu,%mem,etime --sort=-%cpu | head -n 25'
  run "Memory pressure hints" bash -lc 'vmstat 1 5 || true'
  run "Kernel ring buffer (recent, last ~300 lines)" bash -lc 'dmesg -T | tail -n 300'

  section "Storage health and mount configuration"
  run "Mounts, filesystem types, utilization" bash -lc 'df -hT; echo; mount | sed -n "1,200p"'
  run "Block devices and filesystems" bash -lc 'lsblk -f; echo; lsblk -o NAME,SIZE,TYPE,FSTYPE,FSVER,FSUSE%,MOUNTPOINTS,MODEL,SERIAL 2>/dev/null || true'
  run "fstab and mount-related systemd units" bash -lc 'cat /etc/fstab 2>/dev/null || true; echo; systemctl list-units --type=mount --all --no-pager || true'

  # SMART data is very useful for spotting impending disk issues & performance degradation.
  if command -v smartctl >/dev/null 2>&1; then
    section "SMART / disk diagnostics (if available)"
    run "SMART devices scan" bash -lc 'smartctl --scan-open || true'
    # Try common device nodes (safe to fail); on Pi with USB, device often /dev/sda
    run "SMART summary (best effort)" bash -lc 'for d in /dev/sd[a-z] /dev/nvme0n1; do [ -b "$d" ] && echo "--- $d ---" && smartctl -H -A "$d" || true; done'
  else
    section "SMART / disk diagnostics"
    echo "smartctl not installed; consider: sudo apt-get install smartmontools"
  fi

  section "Networking and DNS (performance + misconfig hints)"
  run "Interfaces and addresses" bash -lc 'ip -br addr || true; echo; ip -s link || true'
  run "Routes" bash -lc 'ip route show || true'
  run "DNS resolver config" bash -lc 'resolvectl status 2>/dev/null || (cat /etc/resolv.conf 2>/dev/null || true)'
  run "Listening sockets (top offenders)" bash -lc 'ss -tulpn 2>/dev/null | head -n 200 || true'

  section "Systemd health (common misconfigs show here)"
  run "Failed units" bash -lc 'systemctl --failed --no-pager || true'
  run "Units in error/warning state (last 24h, priority=warning..emerg)" bash -lc "journalctl --since \"$J_SINCE\" -p warning..emerg --no-pager -o short-iso | tail -n 2000"

  section "Boot and service churn (performance regressions often here)"
  run "Boot time breakdown" bash -lc 'systemd-analyze time 2>/dev/null || true; echo; systemd-analyze blame 2>/dev/null | head -n 50 || true'
  run "Critical chain" bash -lc 'systemd-analyze critical-chain 2>/dev/null || true'

  section "Kernel / OOM / throttling / resource pressure signals"
  # OOM kills & CPU throttling are very relevant on Raspberry Pi.
  run "OOM and memory-related journal entries (24h)" bash -lc "journalctl --since \"$J_SINCE\" --no-pager -o short-iso | egrep -i 'oom|out of memory|killed process|memory cgroup|invoked oom-killer' || true"
  run "Thermal / throttling status (Pi-specific if vcgencmd exists)" bash -lc 'command -v vcgencmd >/dev/null 2>&1 && (vcgencmd get_throttled; vcgencmd measure_temp; vcgencmd measure_clock arm) || echo "vcgencmd not available"'
  run "CPU frequency governor (if available)" bash -lc 'for f in /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor /sys/devices/system/cpu/cpufreq/policy0/scaling_governor; do [ -f "$f" ] && echo "$f: $(cat "$f")"; done || true'

  section "Package management and updates (breakages + reboots + daemon restarts)"
  run "Recent apt history (tail)" bash -lc 'test -f /var/log/apt/history.log && tail -n 200 /var/log/apt/history.log || true'
  run "Unattended upgrades logs (tail)" bash -lc 'ls -1 /var/log/unattended-upgrades/* 2>/dev/null || true; echo; tail -n 200 /var/log/unattended-upgrades/unattended-upgrades.log 2>/dev/null || true'
  run "Pending reboot indicators" bash -lc 'test -f /var/run/reboot-required && cat /var/run/reboot-required || echo "no /var/run/reboot-required"'

  section "Authentication / access anomalies (misconfig + security hygiene)"
  run "SSH auth-related events (24h)" bash -lc "journalctl --since \"$J_SINCE\" -u ssh --no-pager -o short-iso 2>/dev/null || journalctl --since \"$J_SINCE\" SYSLOG_IDENTIFIER=sshd --no-pager -o short-iso || true"

  section "High-signal journalctl slices (last 24h)"
  echo "Note: This is a curated slice (warning..emerg already included). Below are the last ~2500 entries overall to capture context."
  run "Journal tail (24h, last ~2500 lines)" bash -lc "journalctl --since \"$J_SINCE\" --no-pager -o short-iso | tail -n 2500"

  section "End"
  echo "output_file: $OUTFILE"
} > "$OUTFILE"

chmod 0644 "$OUTFILE"
echo "$OUTFILE"

