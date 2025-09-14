#!/usr/bin/env bash
[ -f "/usr/local/bin/.daily_reboot" ] && DAILY_REBOOT_ENABLED=$(cat "/usr/local/bin/.daily_reboot")
toggle_daily_reboot(){ if [ "$DAILY_REBOOT_ENABLED" -eq 1 ]; then echo 0 > "/usr/local/bin/.daily_reboot"; DAILY_REBOOT_ENABLED=0; log "Daily reboot disabled"; else echo 1 > "/usr/local/bin/.daily_reboot"; DAILY_REBOOT_ENABLED=1; log "Daily reboot enabled"; fi; update_motd; }
toggle_daily_reboot
