### networkmanager_migrate

Migrates Ubuntu networking from systemd-networkd/netplan-wpa to NetworkManager.

**Warning:** this changes networking and may interrupt SSH. By default, the role schedules an automatic rollback after 5 minutes unless it can reconnect and cancel the rollback.

Variables:
- nm_migrate_enable_rollback (default true)
- nm_migrate_rollback_delay_minutes (default 5)
- nm_migrate_wait_timeout (default 300)
- nm_migrate_reboot (default false)

